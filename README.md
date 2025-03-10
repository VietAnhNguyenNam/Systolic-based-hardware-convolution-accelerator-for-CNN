# Systolic-based-hardware-convolution-accelerator-for-CNN

## Introduction

This is the design for a hardware accelerator for image convolution in Convolutional Neural Network (CNN). The design of this accelerator is based on the systolic architecture. The philosophy of systolic architecture is to reuse the input data as many times as possible before returning the output values to memory to reduce the Von Neumann bottleneck. The data are propagated through many processing elements (PEs), a set of PEs connected together is called a systolic array (SA), and it can be organized as a sequence, a grid, etc. The utilization of data through PEs equips the SA with different dataflow. In this design, I will use Triangular Input Movement dataflow, which was proposed in [this paper](https://arxiv.org/abs/2408.01254).

## Dataflow

The TrIM dataflow can be briefly explained by taking an example. Suppose we want to convolve (valid padding) an $8 \times 8$ matrix $(I=8)$ with a $3 \times 3$ kernel $(K=3)$:

$$\begin{bmatrix}
1 & 2 & \cdots & 8 \\
9 & 10 & \cdots & 16 \\
\vdots & \vdots & \ddots & \vdots \\
57 & 58 & \cdots & 64
\end{bmatrix}
*
\begin{bmatrix}
A & B & C \\
D & E & F \\
G & H & I
\end{bmatrix}$$

The procedure of this dataflow is described in the image below:

![dataflow](https://github.com/user-attachments/assets/2294fe36-f92d-4ea2-af8c-b61f275360a9)

Each block denotes a cycle during processing, the order is from left to right, top to bottom. The bold border grid is the SA, each cell in the grid is PE; those with light borders are shift registers. Weights are preloaded to PEs and stay still during processing. Inputs are first loaded to PEs and then move horizontally. Each PE acts as a MAC, it produces a partial sum and feeds it to the partial sum input of the underlying PE. When coming out of the PEs in the last row, these partial sums are added together to produce the final output element.

There are 4 stages:

- **(0)** is weights and bias loading.
- **(1)** load inputs to fill up the shift registers.
- **(2)** is the main operation, this stage is repeated until reaching the end of input matrix.
- **(3)** is when the system working on some last outputs.

Each row of PEs in SA has 6 operation modes:

- **<ins>w</ins>eight:** load weights.
- **<ins>b</ins>ias:** load bias and matrix size.
- **<ins>n</ins>ew:** load inputs externally.
- **<ins>s</ins>hift:** shift data in SA to the left, load external input for the rightmost PE.
- **<ins>i</ins>nherit:** get data from some leftmost shift registers and fill them to the PEs in the upper row.
- **<ins>h</ins>alt:** stop working.

A state is made up from the combination of operation modes of each row from top to bottom, such as: `nhh` (short for <ins>n</ins>ew-<ins>h</ins>alt-<ins>h</ins>alt) or `iis` (short for <ins>i</ins>nherit-<ins>i</ins>nherit-<ins>s</ins>hift).

Here is the explaination for the procedure:

- In stage **(0)**, weights are transferred to the destination PEs by propagating through the above PEs. PEs halt if there weren't any weights reached to them. Bias and matrix size are loaded at the same time. This stage should take $K+1=4$ working cycles to complete.
- In stage **(1)**, each PEs row first goes to *new* mode, the lower row delay going to *new* mode one cycle compared to the above row, before that, they stay in *halt*. After *new* mode, they go to *shift* mode and remain in *shift* mode until the end of the stage. This stage ends when the first PEs row has 0 element left to reach the end of the row in the input matrix, the second row has 1 left, and the third row has 2 left. This stage should take $I-(K-1)=6$ working cycles to complete, with `nhh`, `snh` and `ssn` each takes 1 cycle, `sss` takes $I-(K-1)-K=3$ cycles.
- Stage **(2)** starts with finishing shifting for the second and third rows. At the moment, the first row is currently completed with one row and want the inputs of the next row, which are available at the $K$ leftmost shift registers of the underlying row, so it goes to *inherit* mode. The same thing happens for the second row in the next cycle. For the last row, i.e. the third row, it will not go to *inherit* but *new* mode, then *shift* mode after it. After `iin`, the system will go back to `iis`, and this state will repeat many times before going to `sis` and `sss` due to running out of valid inherit data. This stage is repeated until reaching the end of the input matrix. The stage should take $I-(K-1)=6$ working cycles to complete for each iteration, with `iss`, `iis` and `iin` each takes 1 working cycle, the repetition of `iis` takes $I-(K-1)-K-(K-1)=1$ cycle(s), and `sis`, `sss` each takes 1 cycle.
- In stage **(3)**, as soon as a row of SA completes a row in the input matrix, it will go to *halt* mode, and the rows haven't finished will keep shifting. This stage takes 2 working cycles for `hss` and `hhs` before going to `hhh` state.

## Design Specification

The code is written in VHDL, the top module is `FSM_and_Slice.vhd`, this module uses AXI4-Stream interface for both input and output. Only three ports of AXI4-Stream are needed in this design: `TDATA`, `TVALID` and `TREADY`. The design is currently fixed for $3 \times 3$ kernel and 5 square matrix sizes: 14, 28, 56, 112, 224 (encoded respectively as: `000`, `001`, `010`, `011`, `100`); but all these things can easily expand by changing the generic and some slightly changing in the code. The type and bitwidth of data are listed in the table below:

|        | type  |
|--------|-------|
| input  | uint8 |
| weight | int8  |
| bias   | int32 |
| output | int32 |

Inputs are image pixels, so they should be `uint8`. Weights and biases are quantized to `int8` to `int32` using PTQ or QAT technique when manipulating with the CNN model for hardware-friendly computation. Outputs should be integers since there is no division. The width of output is the same as bias due to: (a) an observation that the values of biases and partial sums are quite small compared to 32-bit width, so the final outputs don't need to expand the bitwidth beyond 32 bits (should take further consideration); and (b) the kernel is quite small and so the number of arithmetic operations, then the width partial sum cannot reach 32-bit. The outputs must be quantized to `uint8` before feeding back as the input of the next layer in CNN.

For $3 \times 3$ kernel, the maximum number of newly loaded inputs required at a time is 5, so the minimum width of input bus is 40 bits. This number is rounded up to 64 bits to align with the interface of other modules.

## Usage

External inputs data for each state is packed to a single 64-bit little endian word, this word will be fed to `s_axis_tdata` port of input interface. Different states require different orders in packing. Here are the conventions for ease of reading:
- `n0`, `n1`, `n2` are inputs in *new* mode, counts from the left to the right PEs.
- `s0`, `s1`, `s2` are inputs in *shift* mode, counts from the top to the bottom PEs.
- `w0`, `w1`, `w2` are inputs in *weight* mode, counts from the left to the right PEs.
- `b3`, `b2`, `b1`, `b0` are bytes of the bias, indexing as little endian; `sz` is the encoded matrix size, currently only use the last 3 bits, but still occupies a byte.
- `[]` brackets represents the boundary of a byte, `[-]` represents don't-care byte.

Here is that packing order for each state:

| State         | Packing order                   |
|---------------|--------------------------------:|
| whh, wwh, www | `[-][-][-][-][-][w2][w1][w0]`   |
| bbb           | `[-][-][-][sz][b3][b2][b1][b0]` |
| nhh, iin      | `[-][-][-][-][-][n2][n1][n0]`   |
| snh           | `[-][-][-][-][s0][n2][n1][n0]`  |
| snh           | `[-][-][-][s1][s0][n2][n1][n0]` |
| sss           | `[-][-][-][-][-][s2][s1][s0]`   |
| iss, sis, hss | `[-][-][-][-][-][-][s1][s0]`    |
| iis, hhs      | `[-][-][-][-][-][-][-][s0]`     |

Valid inputs should be held at the input port and wait for `TREADY` signal. Some mechanisms like using AXI-Stream data FIFO can be used at input and output ports to get rid of waiting but still obey the AXI protocol.

Output can be obtained with no extra work.

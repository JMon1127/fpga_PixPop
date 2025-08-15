import cocotb
from cocotb.triggers import RisingEdge, Timer

import random
@cocotb.test()
async def run_test(dut):
    # init
    dut.SYS_RST_N.value = 0
    dut.I_GS_DATA_VALID.value = 0

    # clock routine
    async def clock_gen():
        while True:
            dut.SYS_CLK.value = 0
            await Timer(4, units="ns")
            dut.SYS_CLK.value = 1
            await Timer(4, units="ns")

    cocotb.start_soon(clock_gen())

    # wait 10 cycles
    for _ in range(10):
        await RisingEdge(dut.SYS_CLK)

    # let out of reset
    dut.SYS_RST_N.value = 1

    # mirror generics
    NUM_LINES    = int(dut.G_NUM_LINES)
    IMG_ROW_SIZE = int(dut.G_IMG_ROW_SIZE)

    expected_row = 0
    expected_col = 0

    # inject pixel data
    for frame in range(2):
        for r in range(NUM_LINES):
            for c in range(IMG_ROW_SIZE):
                # inject pixel data
                dut.I_GS_DATA.value = random.randint(0, 255)
                dut.I_GS_DATA_VALID.value = 1
                await RisingEdge(dut.SYS_CLK)

                # # Update expected values
                # if expected_row == NUM_LINES - 1 and expected_col == IMG_ROW_SIZE - 1:
                #     expected_row = 0
                #     expected_col = 0
                # elif expected_col == IMG_ROW_SIZE - 1:
                #     expected_col = 0
                #     expected_row += 1
                # else:
                #     expected_col += 1

                # toggle valid signal
                dut.I_GS_DATA_VALID.value = 0
                await RisingEdge(dut.SYS_CLK)

                # # Check output matches expected
                # assert int(dut.s_row_cnt.value) == expected_row, \
                #     f"Row mismatch: got {int(dut.s_row_cnt.value)}, expected {expected_row}"
                # assert int(dut.s_col_cnt.value) == expected_col, \
                #     f"Col mismatch: got {int(dut.s_col_cnt.value)}, expected {expected_col}"

        # Insert a gap with no valid pixels
        dut.I_GS_DATA_VALID.value = 0
        for _ in range(3):
            await RisingEdge(dut.SYS_CLK)

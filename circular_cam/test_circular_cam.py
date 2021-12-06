import cocotb
from cocotb.result import TestFailure, TestSuccess
from cocotb.triggers import *
from cocotb.clock import Clock
import logging


async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units='ns')
    reset_n.value = 1
    reset_n._log.info("Reset complete")


async def fill_buffer(dut, values):
    dut.wr_en.value = 1
    for value in values:
        dut.inp.value = value
        await ClockCycles(dut.clk, 1)
    dut.wr_en.value = 0


def print_buffer(dut):
    """
    Debugging utility to dump the state of the buffer
    """
    dut.buffer._log.debug(f"Next: {dut.next.value}")
    for i in range(64):
        dut.buffer._log.debug(f"{i:02d} {dut.buffer[i].value}")


async def init_tests(dut):
    """
    Common test initialization code
    """
    # Create a clock
    cocotb.fork(Clock(dut.clk, 10, 'ns').start())

    ##dut.buffer._log.setLevel(logging.DEBUG)
    ##dut._log.setLevel(logging.DEBUG)

    # Reset the DUT
    await reset_dut(dut.rst_n, 20)

    # Put some data into the buffer
    await fill_buffer(dut, range(64))
    await ClockCycles(dut.clk, 1)


@cocotb.test()
async def test_circular_cam_hit(dut):
    """
    Test the ciruclar CAM hit functionality.
    """
    await init_tests(dut)

    # Perform some successful lookups
    for x in [1, 10, 42, 63]:  # arbitrary values in the buffer
        dut.rd_en.value = 1
        dut.inp.value = x
        await ClockCycles(dut.clk, 1)
        dut._log.debug(f'H {dut.inp.value}: {dut.index.value} [{dut.index_valid.value}]')
        assert dut.index_valid == 1 and dut.index == x
        dut.rd_en.value = 0

    raise TestSuccess()


@cocotb.test()
async def test_circular_cam_miss(dut):
    """
    Test the ciruclar CAM miss functionality.
    """
    await init_tests(dut)

    # Perform some unsuccessful lookups
    for x in [100, 424242, 64]:  # arbitrary values not in the buffer
        dut.rd_en.value = 1
        dut.inp.value = x
        await ClockCycles(dut.clk, 1)
        dut._log.debug(f'M {dut.inp.value}: {dut.index.value} [{dut.index_valid.value}]')
        assert dut.index_valid == 0
        dut.rd_en.value = 0

    raise TestSuccess()


@cocotb.test()
async def test_circular_cam_store_and_read(dut):
    """
    Test the circular CAM miss/store/hit cycle
    """
    await init_tests(dut)

    data = [0xffffff, 0x47ba33]
    # Do a couple of lookups and verify they are misses
    for x in data:
        dut.rd_en.value = 1
        dut.wr_en.value = 1
        dut.inp.value = x
        await ClockCycles(dut.clk, 1)
        dut._log.debug(f'M {dut.inp.value}: {dut.index.value} [{dut.index_valid.value}]')
        assert dut.index_valid == 0
        dut.rd_en.value = 0
        dut.wr_en.value = 0
    
    await ClockCycles(dut.clk, 1)
    print_buffer(dut)
    # Do the same lookups and verify they are hits
    for i, x in enumerate(data):
        dut.rd_en.value = 1
        dut.inp.value = x
        await ClockCycles(dut.clk, 1)
        dut._log.debug(f'H {dut.inp.value}: {dut.index.value} [{dut.index_valid.value}]')
        assert dut.index_valid == 1 and dut.index.value.integer == i

    raise TestSuccess()
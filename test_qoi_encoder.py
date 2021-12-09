import cocotb
from cocotb.result import TestFailure, TestSuccess
from cocotb.triggers import *
from cocotb.clock import Clock

async def reset_dut(reset_n, duration_ns):
    reset_n.value = 0
    await Timer(duration_ns, units='ns')
    reset_n.value = 1
    reset_n._log.debug("Reset complete")


async def send(dut, pixvalue):
    """
    Send the specified pixel value to the dut.
    @param pixvalue a 3 or 4 byte RGB or RGBA value.
    """
    dut.pixel.value = pixvalue
    dut.pixel_valid.value = 1
    await ClockCycles(dut.clk, num_cycles=1)
    dut.pixel_valid.value = 0

    # wait until the dut starts transmitting
    await RisingEdge(dut.ostream_valid)


async def recv(dut):
    pixvalue = 0
    cnt = 0
    await ReadOnly()
    while dut.ostream_valid.value == 1:
        pixvalue = (pixvalue << 8) | dut.ostream.value
        dut._log.debug("Got byte %x (%x)", dut.ostream.value, pixvalue)
        cnt += 1
        assert cnt <= 5  # 4 data plus 1 header
        await ClockCycles(dut.clk, num_cycles=1)
        # Wait for the read-only phase to ensure all the simulation vars are updated
        await ReadOnly()
    dut._log.debug("Finished recv loop %d", cnt)
    return pixvalue


@cocotb.test()
async def test_qoi_encoder(dut):
    """
    Test the qoi encoder.
    """
    # Create a clock
    cocotb.fork(Clock(dut.clk, 10, 'ns').start())

    # Reset the DUT
    await reset_dut(dut.rst_n, 20)

    # test some 4 byte RGBA
    check_values = [0x22334455, 0x00000000, 0xffffffff, 0xba987654]
    for pv in check_values:
        await send(dut, pv)
        v = await recv(dut)
        assert v == (pv | 0xff00000000)
        await ClockCycles(dut.clk, num_cycles=1)
    raise TestSuccess()
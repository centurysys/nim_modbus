import ../src/nim_modbus as modbus

when isMainModule:
  let ctx = modbus.new_rtu("/dev/ttyS0", B9600, PARITY_NONE, 8, 1)
  
  if ctx != nil:
    echo "libmodbus_new_rtu OK!"
    var ser_type = ctx.rtu_get_serial_mode()
    echo ser_type

    var timeout = ctx.get_byte_timeout()
    echo timeout
    timeout *= 2
    ctx.set_byte_timeout(timeout)
    timeout = ctx.get_byte_timeout()
    echo timeout

    discard ctx.set_slave(1)
    discard ctx.connect()
    var data = ctx.read_input_registers(0, 2)
    echo data

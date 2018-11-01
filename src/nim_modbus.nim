when defined(unix):
  const libname = "libmodbus.so.5"

{.pragma: libmodbus,
  cdecl, dynlib: libname,
.}
{.pragma: prefixed, importc: "modbus_$1".}
{.pragma: same, importc: "$1".}

type
  ModbusStruct {.final, pure.} = object
  Modbus* = ptr ModbusStruct

type
  RtuMode* = enum
    MODBUS_RTU_RS232C
    MODBUS_RTU_RS485
  SerialParity* = enum
    PARITY_EVEN = 'E'
    PARITY_NONE = 'N'
    PARITY_ODD  = 'O'
  SerialBaud* = enum
    B9600  =  9600
    B19200 = 19200
    B38400 = 38400
    

proc modbus_new_rtu(device: cstring, baud: cint, parity: char,
                    data_bit: cint, stop_bit: cint): Modbus {.libmodbus, same.}

proc new_rtu*(device: cstring, baud: SerialBaud, parity: SerialParity,
              data_bit: int, stop_bit: int): Modbus =
  result = modbus_new_rtu(device, cast[cint](baud), cast[char](parity),
                          cast[cint](data_bit), cast[cint](stop_bit))

proc free(ctx: Modbus) {.libmodbus, prefixed.}

proc modbus_rtu_get_serial_mode(ctx: Modbus): cint {.libmodbus, same.}

proc modbus_rtu_set_serial_mode(ctx: Modbus, mode: cint): cint {.libmodbus, same.}

proc rtu_get_serial_mode*(ctx: Modbus): RtuMode =
  var t: int = ctx.modbus_rtu_get_serial_mode()
  if t == 0:
    result = MODBUS_RTU_RS232C
  else:
    result = MODBUS_RTU_RS485

proc rtu_set_serial_mode*(ctx: Modbus, mode: RtuMode): int =
  var mode: cint = case mode:
    of MODBUS_RTU_RS232C:
      0
    of MODBUS_RTU_RS485:
      1
    else:
      raise newException(ValueError, "Invalid Mode")

  result = ctx.modbus_rtu_set_serial_mode(mode)

proc set_slave*(ctx: Modbus, slave: cint): cint {.libmodbus, prefixed.}

proc connect*(ctx: Modbus): cint {.libmodbus, prefixed.}

proc close*(ctx: Modbus) {.libmodbus, prefixed.}

proc flush*(ctx: Modbus) {.libmodbus, prefixed.}

proc modbus_read_input_registers(ctx: Modbus, address: cint, nb: cint,
                                 dest: pointer): cint {.libmodbus, same.}

proc read_input_registers*(ctx: Modbus, address: int, nb: int): seq[uint16] =
  result = newSeq[uint16](nb)
  result[0] = 0
  var res = ctx.modbus_read_input_registers(cint(address), cint(nb),
                                            addr(result[0]))

import posix
import sequtils

when defined(unix):
  const libname = "libmodbus.so.5"

{.pragma: libmodbus,
  cdecl, dynlib: libname,
.}
{.pragma: prefixed, importc: "modbus_$1".}
{.pragma: samename, importc: "$1".}

type
  ModbusStruct {.final, pure.} = object
  Modbus* = ptr ModbusStruct

  Timeval* {.importc: "struct timeval", header: "<sys/select.h>",
            final, pure.} = object
    tv_sec*: clong
    tv_usec*: clong

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
    
# RTU Context
proc modbus_new_rtu(device: cstring, baud: cint, parity: char,
                    data_bit: cint, stop_bit: cint): Modbus {.libmodbus, samename.}

proc new_rtu*(device: cstring, baud: SerialBaud, parity: SerialParity,
              data_bit: int, stop_bit: int): Modbus =
  result = modbus_new_rtu(device, cast[cint](baud), cast[char](parity),
                          cast[cint](data_bit), cast[cint](stop_bit))

proc modbus_rtu_get_serial_mode(ctx: Modbus): cint {.libmodbus, samename.}

proc modbus_rtu_set_serial_mode(ctx: Modbus, mode: cint): cint {.libmodbus, samename.}

proc rtu_get_serial_mode*(ctx: Modbus): RtuMode =
  var mode: int = ctx.modbus_rtu_get_serial_mode()
  if mode == 0:
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

# TCP(IPv4) Context
proc new_tcp*(ip: cstring, port: cint): Modbus {.libmodbus, prefixed.}

# Common
proc free*(ctx: Modbus) {.libmodbus, prefixed.}

proc set_slave*(ctx: Modbus, slave: cint): cint {.libmodbus, prefixed.}

# Connection
proc connect*(ctx: Modbus): cint {.libmodbus, prefixed.}

proc close*(ctx: Modbus) {.libmodbus, prefixed.}

proc flush*(ctx: Modbus) {.libmodbus, prefixed.}

proc modbus_get_byte_timeout(ctx: Modbus, byte_timeout: ptr Timeval) {.libmodbus, samename.}

proc get_byte_timeout*(ctx: Modbus): int =
  var tv: Timeval
  modbus_get_byte_timeout(ctx, addr(tv))
  result = (int(tv.tv_sec) * 1_000 + int(tv.tv_usec) div 1_000)

proc modbus_set_byte_timeout(ctx: Modbus, timeout: ptr Timeval) {.libmodbus, samename.}

proc set_byte_timeout*(ctx: Modbus, timeout: int) =
  var tv: Timeval
  tv.tv_sec = cast[clong](timeout div 1_000)
  tv.tv_usec = cast[clong]((timeout %% 1_000) * 1_000)
  modbus_set_byte_timeout(ctx, addr(tv))

# Client
proc modbus_read_input_registers(ctx: Modbus, address: cint, nb: cint,
                                 dest: pointer): cint {.libmodbus, samename.}

proc read_input_registers*(ctx: Modbus, address: int, nb: int): seq[uint16] =
  result = newSeq[uint16](nb)
  result[0] = 0
  var res = ctx.modbus_read_input_registers(cint(address), cint(nb),
                                            addr(result[0]))

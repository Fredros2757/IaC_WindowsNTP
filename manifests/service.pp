#
#This class handles the w32time service
#
class windowstime::service {
  service { 'w32time':
    ensure => $windowstime::service_ensure,
    enable => $windowstime::service_enable,
  }
}

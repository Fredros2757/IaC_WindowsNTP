#
#This class resyncs time when notified
#
class windowstime::notify {

  exec { 'resync':
    command  => 'w32tm /resync',
    provider => powershell,
    path     => 'c:/windows/system32',
  }
}

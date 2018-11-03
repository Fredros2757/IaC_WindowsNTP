#
#This class handles config for windowstime
#
class windowstime::config {

  if $windowstime::logging {
    exec {'Enabling debug log':
      command  => "w32tm /debug /enable /file:${windowstime::debugpath}\
      /size:${windowstime::debugsize} /entries:${windowstime::debugentryfirst}-${windowstime::debugentrylast}",
      provider => powershell,
      path     => 'c:/windows/system32',
    }
  }

  if !$windowstime::logging {
    exec {'Disabling debug log':
      command  => 'w32tm /debug /disable',
      provider => powershell,
      path     => 'c:/windows/system32',
    }
  }

  exec {'Time culture':
    command  => "Set-Culture ${windowstime::timeculture}",
    provider => powershell,
    path     => 'c:/windows/system32',
  }

  $regvalue = maptoreg($windowstime::servers)
  registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\Type':
    ensure => present,
    type   => string,
    data   => 'NTP'
  }

  registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\NtpServer':
    ensure => present,
    type   => string,
    data   => $regvalue,
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\MaxPosPhaseCorrection':
    ensure => present,
    type   => 'dword',
    data   => $windowstime::max_pos_phase_correction,
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\MaxNegPhaseCorrection':
    ensure => present,
    type   => 'dword',
    data   => $windowstime::max_neg_phase_correction,
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\TimeProviders\\NtpClient\\SpecialPollInterval':
    ensure => present,
    type   => 'dword',
    data   => $windowstime::special_poll_interval,
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\MaxPollInterval':
    ensure => present,
    type   => 'dword',
    data   => $windowstime::max_poll_interval,
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\MinPollInterval':
    ensure => present,
    type   => 'dword',
    data   => $windowstime::min_poll_interval,
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\LargePhaseOffset':
    ensure => present,
    type   => 'dword',
    data   => $windowstime::large_phase_offset,
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\UpdateInterval':
    ensure => present,
    type   => 'dword',
    data   => $windowstime::update_interval,
  }

  exec { 'c:/Windows/System32/w32tm.exe /resync':
    refreshonly => true,
  }

  if $windowstime::timezone {
    validate_re($windowstime::timezone, $windowstime::timezones, 'The specified string is not a valid Timezone')
    if $windowstime::timezone != $facts['timezone'] {
      $system32dir = $facts['os']['windows']['system32']
      exec { 'Sets specified timezone':
        command   => "tzutil /s ${windowstime::timezone}",
        provider  => powershell,
        path      => system32dir,
        logoutput => true,
      }
    }
  }
}

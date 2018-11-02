# Class: windowstime
# ===========================
#
# A module to manage windows time configuration.
#
# Parameters
# ----------
#
#
# * 'servers'
# A hash of time servers, including the configuration flags as follows:
#
# 0x01 SpecialInterval
# 0x02 UseAsFallbackOnly
# 0x04 SymmatricActive
# 0x08 Client
# The Params class contains some sane defaults:
#   $servers = { 'pool.ntp.org'     => '0x01',
#               'time.windows.com' => '0x01',
#               'time.nist.gov'    => '0x02',
#  }
# Examples
# --------
#
# Set custom timezone  
#    class { 'windowstime':
#      servers => { 'pool.ntp.org'     => '0x01',
#                   'time.windows.com' => '0x01',
#                 }
#      timezone => UTC,
#    }
#
# Enable debugging with default values
#    class { 'windowstime':
#      servers => { 'pool.ntp.org'     => '0x01',
#                   'time.windows.com' => '0x01',
#                 }
#      logging => true,
#    }
#
# Enable debugging with custom path, max filesize and levels of entries
#    class { 'windowstime':
#      servers => { 'pool.ntp.org'     => '0x01',
#                   'time.windows.com' => '0x01',
#                 }
#      logging => true,
#      debugpath => C:\logs\mylog.log,
#      debugsize => 100000,
#      debugentryfirst => 5,
#      debugentrylast => 290,
#    }
#
# Authors
# -------
#
# Nicolas Corrarello <nicolas@puppet.com>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#
class windowstime (
  Optional[Hash] $servers,
  Optional[String]  $timezone = undef,
  Optional[Array]   $timezones,
  Optional[Boolean] $logging = undef,
  Optional[String]  $debugpath,
  Optional[Integer] $debugsize,
  Optional[Integer] $debugentryfirst,
  Optional[Integer] $debugentrylast,
  Optional[String]  $timeculture,
  Optional[Integer] $max_pos_phase_correction,
  Optional[Integer] $max_neg_phase_correction,
  Optional[Integer] $special_poll_interval,
  Optional[Integer] $max_poll_interval,
  Optional[Integer] $min_poll_interval,
  Optional[Integer] $large_phase_offset,
  Optional[Integer] $update_interval,
) {

  if $logging {
    exec {'Enabling debug log':
      command  => "w32tm /debug /enable /file:${debugpath} /size:${debugsize} /entries:${debugentryfirst}-${debugentrylast}",
      provider => powershell,
      path     => 'c:/windows/system32',
    }
  }

  if !$logging {
    exec {'Disabling debug log':
      command  => 'w32tm /debug /disable',
      provider => powershell,
      path     => 'c:/windows/system32',
    }
  }

  exec {'Time culture':
    command  => "Set-Culture ${timeculture}",
    provider => powershell,
    path     => 'c:/windows/system32',
    #onlyif   => "(Get-Culture | %$_.Name;}) -ne ${timeculture}", would have worked but powershell is bugged
  }

  $regvalue = maptoreg($servers)
  registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\Type':
    ensure => present,
    type   => string,
    data   => 'NTP'
  }

  registry_value { 'HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters\NtpServer':
    ensure => present,
    type   => string,
    data   => $regvalue,
    notify => Service['w32time'],
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\MaxPosPhaseCorrection':
    ensure => present,
    type   => 'dword',
    data   => $max_pos_phase_correction,
    notify => Service['w32time'],
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\MaxNegPhaseCorrection':
    ensure => present,
    type   => 'dword',
    data   => $max_neg_phase_correction,
    notify => Service['w32time'],
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\TimeProviders\\NtpClient\\SpecialPollInterval':
    ensure => present,
    type   => 'dword',
    data   => $special_poll_interval,
    notify => Service['w32time'],
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\MaxPollInterval':
    ensure => present,
    type   => 'dword',
    data   => $special_poll_interval,
    notify => Service['w32time'],
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\MinPollInterval':
    ensure => present,
    type   => 'dword',
    data   => $special_poll_interval,
    notify => Service['w32time'],
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\LargePhaseOffset':
    ensure => present,
    type   => 'dword',
    data   => $large_phase_offset,
    notify => Service['w32time'],
  }

  registry_value { 'HKLM\\SYSTEM\\CurrentControlSet\\Services\\W32Time\\Config\\UpdateInterval':
    ensure => present,
    type   => 'dword',
    data   => $update_interval,
    notify => Service['w32time'],
  }

  exec { 'c:/Windows/System32/w32tm.exe /resync':
    refreshonly => true,
  }

  service { 'w32time':
    ensure => running,
    enable => true,
    notify => Exec['c:/Windows/System32/w32tm.exe /resync'],
  }

  if $timezone {
    validate_re($timezone, $timezones, 'The specified string is not a valid Timezone')
    if $timezone != $facts['timezone'] {
      $system32dir = $facts['os']['windows']['system32']
      exec { 'Sets specified timezone':
        command   => "tzutil /s ${timezone}",
        provider  => powershell,
        path      => system32dir,
        logoutput => true,
      }
    }
  }
}

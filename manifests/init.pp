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
#      debugpath => 'c:\logs\mylog.log',
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
  Integer                    $debugentryfirst,
  Integer                    $debugentrylast,
  String                     $debugpath,
  Integer                    $debugsize,
  Boolean                    $logging,
  Hash                       $servers,
  Boolean                    $service_enable,
  Enum['running', 'stopped'] $service_ensure,
  String                     $service_provider,
  String                     $timezone,
  Array                      $timezones,
  Optional[Integer]          $large_phase_offset,
  Optional[Integer]          $max_neg_phase_correction,
  Optional[Integer]          $max_poll_interval,
  Optional[Integer]          $max_pos_phase_correction,
  Optional[Integer]          $min_poll_interval,
  Optional[Integer]          $special_poll_interval,
  Optional[String]           $timeculture,
  Optional[Integer]          $update_interval,
) {
  contain windowstime::config
  contain windowstime::service
  contain windowstime::notify

  Class['::windowstime::config']
  -> Class['::windowstime::service']
  -> Class['::windowstime::notify']
}

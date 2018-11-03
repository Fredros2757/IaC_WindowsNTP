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
  Optional[Hash]    $servers,
  Optional[String]  $timezone = undef,
  Optional[Array]   $timezones,
  Optional[Boolean] $logging,
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
  String            $service_ensure,
  Boolean           $service_enable,
  String            $service_notify,
  String            $service_provider,
) {
  contain windowstime::config
  contain windowstime::service
  Class['::windowstime::config'] -> Class['::windowstime::service']
}

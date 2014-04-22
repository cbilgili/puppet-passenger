# Class: passenger::params
#
#
class passenger::params {
  $passenger_ruby                 = "/opt/ruby-2.0.0-p353/bin/ruby"
  $passenger_version              = "4.0.37"
  $gem_path                       = "/opt/ruby-2.0.0-p353/lib/ruby/gems/2.0.0"
  $gem_binary_path                = "/opt/ruby-2.0.0-p353/bin"
  $passenger_start_timeout        = "400"
  $passenger_max_pool_size        = "15"
  $passenger_pool_idle_time       = "0"
  $passenger_max_requests         = "5000"
  $passenger_min_instances        = "3"
  $passenger_stat_throttle_rate   = "50"
}
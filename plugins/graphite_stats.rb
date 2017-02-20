#! /usr/bin/env ruby
#  encoding: UTF-8
#   grahpite_stats.rb
#
# DESCRIPTION:
#   This plugin uses /proc to collect basic system metrics,
#   produces Graphite formated output.
#
#   Author / Maintainer: Eric Lakich (github: ericlakich)
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: socket
#
# USAGE:
#
# NOTES:
#
# LICENSE:
#

require 'sensu-plugin/metric/cli'
require 'socket'

class VMStat < Sensu::Plugin::Metric::CLI::Graphite
  option :scheme,
         description: 'Metric naming scheme, text to prepend to .$parent.$child',
         long: '--scheme SCHEME',
         default: "sensu.#{Socket.gethostname().gsub(".","_")}.system"

  def run
    timestamp = Time.now.to_i

    ############ MEMORY #################
    mem_result = Array.new
    # memory.swap_total
    mem_result[0] = `cat /proc/meminfo|grep "^SwapTotal"|awk '{print $2}'`
    # memory.swap_free
    mem_result[1] = `cat /proc/meminfo|grep "^SwapTotal"|awk '{print $2}'`
    # memory.total
    mem_result[2] = `cat /proc/meminfo|grep "^MemTotal"|awk '{print $2}'`
    # memory.free
    mem_result[3] = `cat /proc/meminfo|grep "^MemFree"|awk '{print $2}'`
    # memory.available
    mem_result[4] = `cat /proc/meminfo|grep "^MemAvailable"|awk '{print $2}'`
    # memory.buffers
    mem_result[5] = `cat /proc/meminfo|grep "^Buffers"|awk '{print $2}'`
    # memory.cache
    mem_result[6] = `cat /proc/meminfo|grep "^Cached"|awk '{print $2}'`

    metrics = {
      memory: {
        swap_total: mem_result[0],
        swap_free: mem_result[1],
        total: mem_result[2],
        free: mem_result[3],
        avaialable: mem_result[4],
        buffers: mem_result[5],
        cache: mem_result[6]
      }
    }

    metrics.each do |parent, children|
      children.each do |child, value|
        output [config[:scheme], parent, child].join('.'), value.gsub(/\s+/, ' ').strip, timestamp
      end
    end

    ############ DISK #################
    input = `cat /proc/diskstats`

    input.each_line do |line|
      disk_result = line.gsub(/\s+/m, ' ').strip.split(" ")
      output [config[:scheme], "disk", disk_result[2], "num_major"].join('.'), disk_result[0], timestamp
      output [config[:scheme], "disk", disk_result[2], "num_minor"].join('.'), disk_result[1], timestamp
      output [config[:scheme], "disk", disk_result[2], "read", "completed"].join('.'), disk_result[3], timestamp
      output [config[:scheme], "disk", disk_result[2], "read", "merged"].join('.'), disk_result[4], timestamp
      output [config[:scheme], "disk", disk_result[2], "read" "sectors"].join('.'), disk_result[5], timestamp
      output [config[:scheme], "disk", disk_result[2], "read", "time"].join('.'), disk_result[6], timestamp
      output [config[:scheme], "disk", disk_result[2], "write", "completed"].join('.'), disk_result[7], timestamp
      output [config[:scheme], "disk", disk_result[2], "write", "merged"].join('.'), disk_result[8], timestamp
      output [config[:scheme], "disk", disk_result[2], "write", "sectors"].join('.'), disk_result[9], timestamp
      output [config[:scheme], "disk", disk_result[2], "write", "time"].join('.'), disk_result[10], timestamp
      output [config[:scheme], "disk", disk_result[2], "io", "ps"].join('.'), disk_result[11], timestamp
      output [config[:scheme], "disk", disk_result[2], "io", "time"].join('.'), disk_result[12], timestamp
      output [config[:scheme], "disk", disk_result[2], "io", "weighted_time"].join('.'), disk_result[13], timestamp
    end

    input = `df --type=xfs --type=ext4 --type=ext3|grep -v Filesystem`

    input.each_line do |line|
      disk_result = line.gsub(/\s+/m, ' ').strip.split(" ")
      output [config[:scheme], "disk", disk_result[0].tr('/', '_'), "usage", "used"].join('.'), disk_result[2], timestamp
      output [config[:scheme], "disk", disk_result[0].tr('/', '_'), "usage", "avail"].join('.'), disk_result[3], timestamp
      output [config[:scheme], "disk", disk_result[0].tr('/', '_'), "usage", "used_pct"].join('.'), disk_result[4].tr('%', ''), timestamp
    end

    ############ Compute #################
    input = `cat /proc/stat`

    input.each_line do |line|
      if line.start_with?('cpu')
        cpu_result = line.gsub(/\s+/m, ' ').strip.split(" ")

        time_user = cpu_result[1]
        time_nice = cpu_result[2]
        time_system = cpu_result[3]
        time_idle = cpu_result[4]
        time_io_wait = cpu_result[5]
        time_irq = cpu_result[5]
        time_soft_irq = cpu_result[5]

        time_total = time_user.to_f + time_nice.to_f + time_system.to_f + time_idle.to_f + time_io_wait.to_f + time_irq.to_f + time_soft_irq.to_f

        pct_user = (cpu_result[1].to_f / time_total.to_f) * 100
        pct_nice = (cpu_result[2].to_f / time_total.to_f) * 100
        pct_system = (cpu_result[3].to_f / time_total.to_f) * 100
        pct_idle = (cpu_result[4].to_f / time_total.to_f) * 100
        pct_io_wait = (cpu_result[5].to_f / time_total.to_f) * 100
        pct_irq = (cpu_result[6].to_f / time_total.to_f) * 100
        pct_soft_irq = (cpu_result[7].to_f / time_total.to_f) * 100

        output [config[:scheme], "compute", cpu_result[0], "pct", "user"].join('.'), pct_user.to_i, timestamp
        output [config[:scheme], "compute", cpu_result[0], "pct", "nice"].join('.'), pct_nice.to_i, timestamp
        output [config[:scheme], "compute", cpu_result[0], "pct", "system"].join('.'), pct_system.to_i, timestamp
        output [config[:scheme], "compute", cpu_result[0], "pct", "idle"].join('.'), pct_idle.to_i, timestamp
        output [config[:scheme], "compute", cpu_result[0], "pct", "io_wait"].join('.'), pct_io_wait.to_i, timestamp
        output [config[:scheme], "compute", cpu_result[0], "pct", "irq"].join('.'), pct_irq.to_i, timestamp
        output [config[:scheme], "compute", cpu_result[0], "pct", "soft_irq"].join('.'), pct_soft_irq.to_i, timestamp
      end

      input = `cat /proc/loadavg`
      load_result = input.gsub(/\s+/m, ' ').strip.split(" ")
      output [config[:scheme], "load", "1min"].join('.'), load_result[0], timestamp
      output [config[:scheme], "load", "5min"].join('.'), load_result[1], timestamp
      output [config[:scheme], "load", "10min"].join('.'), load_result[2], timestamp
    end



    ############ End - Return #################
    ok
  end
end


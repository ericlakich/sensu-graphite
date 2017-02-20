# Sensu Graphite

This plugin is designed to be a Sensu stats emitter for time series tracking of Linux system stats.

## Sensu/Ruby Environment Prerequisites 
gem: sensu-plugin
gem: socket

## Handler

handlers/graphite_tcp.rb - TCP handler for sending stats to Graphite. 

## Plugin

plugins/grahite_stats.rb - This is the main plugin file which structures Linux filesystem data from /proc into Graphite syntax. Modify this file to customize the stats shipped to Grahpite. 

## Conf [Customize these files for your environment]

conf.d/handler_graphite.json - Contains the tcp socket and handler config. Update this file with your Graphite server hostname and your custom Sensu/Ruby command path.

conf.d/check_graphite.json - Adds a check for all "graphite" subscribers. Update this file with your custom Sensu/Ruby command path.


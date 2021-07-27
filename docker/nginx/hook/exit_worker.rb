# frozen_string_literal: true

Userdata.new("redis_#{Process.pid}").client.close

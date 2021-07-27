# frozen_string_literal: true

redis = Userdata.new("redis_#{Process.pid}").redis_connection
redis&.close

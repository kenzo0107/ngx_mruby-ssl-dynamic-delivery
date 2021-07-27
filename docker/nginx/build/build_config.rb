# frozen_string_literal: true

MRuby::Build.new do |conf|
  toolchain :gcc

  conf.gembox 'full-core'

  # Recommended for ngx_mruby
  conf.gem github: 'iij/mruby-env' # ENV object for mruby
  conf.gem github: 'iij/mruby-dir' # Dir class for mruby
  # Digest class for mruby utilizing OpenSSL or Common Crypto
  conf.gem github: 'iij/mruby-digest'
  conf.gem github: 'iij/mruby-process' # Process module for mruby
  conf.gem github: 'iij/mruby-pack' # Array#pack and String#unpack for mruby
  conf.gem github: 'mattn/mruby-json' # JSON parser for mruby
  conf.gem github: 'mattn/mruby-onig-regexp' # regular expression for mruby
  conf.gem github: 'matsumoto-r/mruby-redis' # redis class for mruby
  conf.gem github: 'matsumoto-r/mruby-sleep' # sleep module for mruby
  conf.gem github: 'matsumoto-r/mruby-userdata' # Userdata for mruby
  conf.gem github: 'matsumoto-r/mruby-uname' # system uname bindings for mruby
  conf.gem github: 'matsumoto-r/mruby-mutex' # mutex class for mruby
  # HttpRequest of iij/mruby support mruby/mruby using mruby-uv and mruby-http
  conf.gem github: 'matsumoto-r/mruby-httprequest'
  conf.gem github: 'mattn/mruby-curl' # mruby wrapper for libcurl

  # ngx_mruby extended class
  conf.gem './mrbgems/ngx_mruby_mrblib'
  conf.gem './mrbgems/rack-based-api'

  if %w[development test].include?(ENV['ENVIRONMENT'])
    # テストで利用する
    conf.gem github: 'iij/mruby-mtest'
    enable_debug
    conf.enable_bintest
    conf.enable_test
  end
end

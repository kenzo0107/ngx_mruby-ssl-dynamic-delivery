# frozen_string_literal: true

%w[
  ssl_handshake_handler.rb
].each do |f|
  system "ENVIRONMENT=test mruby hook/#{f}"
end

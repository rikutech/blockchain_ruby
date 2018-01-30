require 'bundler'
require 'securerandom'
require 'json'
require File.dirname(__FILE__) + "/Blockchain"
Bundler.require

node_identifire = SecureRandom.uuid.gsub('-', '')

blockchain = Blockchain.new

post '/transactions/new' do
  return '新しいトランザクション'
end

get '/mine' do
  return '新しいブロックの採掘'
end

get '/chain' do
  response = {
    chain: blockchain.chain,
    length: blockchain.chain.length,
  }
  return [200, response.to_json]
end


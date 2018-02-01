require 'bundler'
require 'securerandom'
require 'json'
require File.dirname(__FILE__) + "/Blockchain"
Bundler.require

$stdout.sync = true
node_identifire = SecureRandom.uuid.gsub('-', '')

blockchain = Blockchain.new

post '/transactions/new' do
  required = ['sender', 'recipient', 'amount']
  data = JSON.parse(request.body.read)
  return [400, 'Missing values'] unless data.keys.all? { |p| required.include?(p) }
  index = blockchain.new_transaction(
    sender: data['sender'],
    recipient: data['recipient'],
    amount: data['amount'])
  return [201, {'message': "transaction added to block #{index}"}.to_json]
end

get '/mine' do
  last_block = blockchain.last_block
  last_proof = last_block[:proof]
  proof = blockchain.proof_of_work(last_proof)

  #プルーフを見つけたことに対する報酬を得る
  #送信者は、採掘者が新しいコインを採掘したことを表すために"0"とする
  blockchain.new_transaction(
    sender: "0",
    recipient: node_identifire,
    amount: 1,
  )

  block = blockchain.new_block(proof)
  response = {
    message: 'U mined a new block!!!1!!!!!111!!!!11!',
    index: block[:index],
    transactions: block[:transactions],
    proof: block[:proof],
    previous_hash: block[:previous_hash],
  }
  return [200, response.to_json]
end

get '/chain' do
  response = {
    chain: blockchain.chain,
    length: blockchain.chain.length,
  }
  return [200, response.to_json]
end

post '/nodes/register' do
  values = JSON.parse(request.body.read)
  nodes = values['nodes']
  if nodes == nil
    return [400, {'message': 'invalid node list'}]
  end

  nodes.each do |node|
    blockchain.register_node(node)
  end

  response = {'message': 'new node successfully added!', 'total_nodes': list(blockchain.nodes)}
  return [201, response.to_json]
end

get '/nodes/resolve' do
  replaced = blockchain.resolve_conflicts

  if replaced
    response = {'message': 'chain replaced', 'new_chain': blockchain.chain}
  else
    response = {'message': 'chain confirmed', 'chain': blockchain.chain}
  end
  return response.to_json
end












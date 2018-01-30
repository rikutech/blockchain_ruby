require 'date'
require 'json'
require 'digest/sha2'

class Blockchain
  attr_reader :chain

  def initialize
    @chain = []
    @current_transactions = []
    new_block(previous_hash: 1, proof: 100)
  end

  def new_block(proof, previous_hash=nil)
    #新しいブロックを作りチェーンに加える
    block = {
      index: chain.length + 1,
      timestamp: Time.now.to_i,
      transactions: @current_transactions,
      proof: proof,
      previous_hash: previous_hash || self.class.hash(@chain[-1])
    }
    @current_transactions = []
    @chain.push(block)
    return block
  end

  def new_transaction(sender:, recipient:, amount:)
    #新しいトランザクションをリストに加える
    @current_transactions.push({sender: sender, recipient: recipient, amount: amount})
    last_block[:index] + 1
  end

  def last_block
    #チェーンの最後のブロックをリターンする
    @chain[-1]
  end


  def proof_of_work(last_proof)
    #proof of workのアルゴリズム
    #hash(pp') の最初の4つが0となるようなp'を探す
    #pは前のプルーフ, p'は新しいプルーフ
    proof = 0
    while self.class.valid_proof(last_proof, proof) === false do
      proof += 1
    end
    return proof
  end

  class << self
    def hash(block)
      #ブロックのSHA-256ハッシュを作る
      # 必ずディクショナリ（辞書型のオブジェクト）がソートされている必要がある。そうでないと、一貫性のないハッシュとなってしまう
      return Digest::SHA256.hexdigest(block.to_json)
    end

    def valid_proof(last_proof, proof)
      guess = "#{last_proof}#{proof}".encode()
      guess_hash = Digest::SHA256.hexdigest(guess)
      return guess_hash[-4, 4] == "0000"
    end
  end
end

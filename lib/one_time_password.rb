# frozen_string_literal: true

# Generate a random six digit and store it in redis against
# the users' email. We then send that token to their email
# address so they can verify that they are who they say they
# are
class OneTimePassword
  def initialize(email)
    @email = email
  end

  def create!
    token = generate_token
    Redis.current.set(key, token)
    token
  end

  def verify(token)
    Redis.current.get(key) == token
  end

  def delete!
    Redis.current.del(key)
  end

  private

  def key
    "auth:#{@email}"
  end

  def generate_token
    6.times.map { rand(10) }.join
  end
end

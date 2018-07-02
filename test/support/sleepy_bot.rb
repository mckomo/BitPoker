# frozen_string_literal: true

class SleepyBot < BitPoker::BotInterface
  def return_after_sleep(value, timeout)
    sleep(timeout)
    value
  end

  def raise_exception
    2 / 0
  end
end

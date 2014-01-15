require 'rake/testtask' 

task :default => "bitpoker:duel"

namespace :bitpoker do
   
   desc "Setup BitPocket"
   task :setup do
      require_relative 'lib/bitpoker'
   end
   
   desc "Play BitPoker"
   task :duel, [:bot_one, :bot_two] => :setup do |t, args|
      
      # Load bots
      bot_one = BitPoker::load_bot( args.bot_one )
      bot_two = BitPoker::load_bot( args.bot_two )
      
      # Init local bot proxy
      proxy_one = BitPoker::BotProxy.new( bot_one )
      proxy_two = BitPoker::BotProxy.new( bot_two )
      
      croupier = BitPoker::Croupier.new
      
      # Init new duel
      duel = BitPoker::Duel.new( croupier, proxy_one, proxy_two )
      
      begin
         until duel.finished? do
            duel.play_round
         end
      rescue BitPoker::BotError => e
         puts "Bot #{e.bot.trigger(:name)} is disqualified. Reason: \"#{e.message}\"."
      end
      p duel.total_score
      
   end
   
   Rake::TestTask.new( :unit ) do |t|
     t.test_files = FileList['test/test_*.rb']
   end
   
end

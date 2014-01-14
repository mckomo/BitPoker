module BitPoker
   
      
   #
   #
   # @author Mckomo
   class Croupier 
      
      attr_reader :rules
      
      include GameLogic
      
      def initialize( rules = {} )
         @rules = setup( rules )
         @prng = Random.new
      end
      
      def call( bot, action, args = [] )
      
         raise ArgumentError, "Croupier plays only with BotProxy." unless bot.kind_of? BotProxyInterface
      
         begin
            # Get bot response within timeout
            bot_response = timeout( @rules[:timeout] ) do
                bot.trigger( action, args )
            end
         rescue Timeout::Error
            raise BitPoker::BotError, "Bot exceeded timeout."
         rescue NotImplementedError
            raise BitPoker::BotError, "Bot does not implement '#{action}' action."
         rescue => e
            raise BitPoker::BotError, "Bot failed during '#{action}' action execution. Error: #{e}."
         end
         
         # Validate response if yield given
         if block_given?
            raise BitPoker::BotError, "Bot response '#{bot_response}' after '#{action} request is invalid." unless yield( bot_response )
         end
         
         bot_response

      end
   
      #
      #
      #
      #
      #
      def parallel_call( bots, action, *args_list )
         
         Parallel.map_with_index( bots, { :in_threads => 2 } ) do |b, i|
            # Get args 
            args = args_list[i] || args_list[0]
            # Call bot with or without yield
            if block_given?
               call( b, action, args ) do |result| 
                  yield( result )
               end
            else
               call( b, action, args )
            end
         end
         
      end
      
      def deal_cards
         [ @prng.rand( Rules::CARD_RANGE ), @prng.rand( Rules::CARD_RANGE ) ]
      end
      
      def setup( rules )
         {
             rounds:       rules[:rounds]     || Rules::ROUNDS,
             min_stake:    rules[:min_stake]  || Rules::MIN_STAKE,
             max_stake:    rules[:max_stake]  || Rules::MAX_STAKE,
             timeout:      rules[:timeout]    || Rules::TIMEOUT,
             card_range:   rules[:card_range] || Rules::CARD_RANGE,
         }
      end
   
   end

   
end
require "timeout"
require "parallel"

require_relative 'bitpoker/bot_interface'
require_relative 'bitpoker/bot_proxy_interface'
require_relative 'bitpoker/bot_proxy'
require_relative 'bitpoker/rules'
require_relative 'bitpoker/game_logic'
require_relative 'bitpoker/croupier'
require_relative 'bitpoker/duel'
require_relative 'bitpoker/round'

# Great game of the BitPoker
#
# @author Mckomo
module BitPoker
   
   VERSION = "0.1.1"
   
   # Load bot from file
   #
   # @raise ArrgumentError
   # @param bot_file [String]
   # @return [BotInterface]
   def self.load_bot( bot_file, bot_dir = "./bot", module_prefix = "Bot" )
   
      # Get path to bot file
      bot_path = "#{bot_dir}/#{bot_file}.rb"      
      
      # Raise exception if bot's file doesn't exist
      raise ArgumentError, "Bot \"#{bot_file}\" does not exist in path \"#{bot_path}\"." unless File.exist?( bot_path )
      
      # Load bot
      require bot_path
      
      # Convert file name to class name
      module_prefix += "::" unless ! module_prefix or module_prefix.empty? 
      klass_name = bot_file.split( '_' ).map { |s| s.capitalize }.join  
      klass = Kernel.const_get( "#{module_prefix}#{klass_name}" )
      
      # Check if bot class implements BotInterface
      raise ArgumentError, "Bot \"#{bot_file}\" does not implement BotInterface." unless klass.ancestors.include?( BitPoker::BotInterface )
      
      # Init bot
      klass.new
      
   end
   
   # Exception raised when a bot breaks rules of the BitPoker
   class BotError < RuntimeError
      
      attr_reader :bot
      
      def initialize( bot, message = "" )
         super( message )
         @bot = bot
      end
      
   end
   
end
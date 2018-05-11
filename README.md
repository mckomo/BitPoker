# BitPoker

Ruby implementation of [BitPoker](http://bitpoker.sfi.org.pl/tutorial/pokaz/4) (polish readers only) game.

## Idea

**In general**: let computer programs play in simplified version of poker.

**For devs**: create an bot that will beat the crap out of opponents.

## Rules of game

In a BitPoker duel participate two bots. Duel has `1000` rounds. Each round consists of following steps.

1. **Rules introduction:** croupier introduces bots with round rules. Bots are sent information about `minimal` and `maximal` number from the card range, `maximal stake` they can bet during betting rounds and `timeout` - maximal duration of bot response.
2. **Card deal:** bots receive random card from `0..4` (min_card .. max_card) range .
3. **First betting round:** bots have to set their bets. Bet value must be from `10..200` (min_stake .. max_stake) range.
	1. If both bets are already `200` (max_stake) go to **step 5**. If bets are even, go to **step 4**.
	2. Otherwise, lower bidder is ask to call the round stake (opponents higher bid). If he agrees, go to next step. If he does not agree, lower bidder folds and loses points equal to his last bet. Higher bidder is a winner and receives score equal to last bet of folding bot. **Round is over**.
4. **Second betting round:** is performed alike first one, however bet minimal value is equal to the stake determined after previous betting round.
5. **Showdown:** croupier sends information to bots about opponent card. If cards are equal, round ends with a draw and result is 0 to 0. Otherwise, bot with lower card loses number of points equal to the round stake and winner receives the equivalent amount of points. **Round is over**.
6. Round result is appended to a total score of the duel. 

It is important for a bot to respect duel rules, otherwise the bot will be disqualified.

**NOTE:** All of highlighted values are fully customizable. Take a peak at `BitPoker::Croupier#setup` method. Also they can be altered during duel (not recommenced so far), so each round can be different. 

##How to start?

Before any action is taken, use [Bundler](http://bundler.io/) to make sure your ruby environment is ready to play BitPoker.

```
gem update --system; gem install bundler # If you don't have Bundler installed
bundle install
```

It's very simple. First of all we need to build our own bot. To do so, create class that implements `BitPoker::BotInterface`. When you finished, place your bot file to `./bot` dir. To be sure that your bot is ready
for every game scenario, play test duel with `DummyBot`. Enter following commands in your console:

```
rake bitpoker:duel[your_bot_name,dummy_bot]
```
When duel is over, you should see result of the duel.

```
[45795, -45795]
```
Now you are ready to fight your friends bots!
##TCPoker
Main reason of creating BitPoker is to create solid foundation for TCPoker - BitPoker over TCP. More to come very soon.

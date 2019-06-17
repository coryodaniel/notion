all:
	mix format
	mix test
	mix credo
	mix dialyzer
	mix docs

all:
	@echo "Compiling..."
	@if [ ! -d "ebin" ]; then mkdir ebin; fi
	@cd src; erl -make
	@echo "Running..."
	@cd ebin; erl -noshell -s server start

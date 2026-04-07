FILTER       = container-writer.lua
STRIP_FILTER = container-strip.lua
STRIP_INPUTS = $(wildcard test/input/strip-*.md)
INPUTS       = $(filter-out $(STRIP_INPUTS), $(wildcard test/input/*.md))
FORMATS      = latex context typst

.PHONY: test test-strip test-quarto test-quarto-strip \
        generate-tests generate-strip-tests clean

test:
	@failed=0; \
	for f in $(INPUTS); do \
		name=$$(basename $$f .md); \
		for fmt in $(FORMATS); do \
			pandoc --lua-filter=$(FILTER) $$f -t $$fmt \
				> /tmp/cw_$${name}_$${fmt}.out \
				2>/tmp/cw_$${name}_$${fmt}.err; \
			stdout_ok=1; stderr_ok=1; \
			if ! diff -q /tmp/cw_$${name}_$${fmt}.out \
					test/expected/$${name}-$${fmt}.out \
					> /dev/null 2>&1; then \
				echo "FAIL: $$name ($$fmt stdout)"; \
				diff /tmp/cw_$${name}_$${fmt}.out \
					test/expected/$${name}-$${fmt}.out; \
				stdout_ok=0; failed=1; \
			fi; \
			if [ -f test/expected/$${name}-$${fmt}.err ]; then \
				if ! diff -q /tmp/cw_$${name}_$${fmt}.err \
						test/expected/$${name}-$${fmt}.err \
						> /dev/null 2>&1; then \
					echo "FAIL: $$name ($$fmt stderr)"; \
					diff /tmp/cw_$${name}_$${fmt}.err \
						test/expected/$${name}-$${fmt}.err; \
					stderr_ok=0; failed=1; \
				fi; \
			elif [ -s /tmp/cw_$${name}_$${fmt}.err ]; then \
				echo "FAIL: $$name ($$fmt unexpected stderr)"; \
				cat /tmp/cw_$${name}_$${fmt}.err; \
				stderr_ok=0; failed=1; \
			fi; \
			[ $$stdout_ok -eq 1 ] && [ $$stderr_ok -eq 1 ] \
				&& echo "PASS: $$name ($$fmt)"; \
		done; \
	done; \
	exit $$failed

test-strip:
	@failed=0; \
	for f in $(STRIP_INPUTS); do \
		name=$$(basename $$f .md); \
		pandoc --lua-filter=$(STRIP_FILTER) \
		       --lua-filter=$(FILTER) $$f -t markdown \
			> /tmp/cw_$${name}.out \
			2>/tmp/cw_$${name}.err; \
		stdout_ok=1; stderr_ok=1; \
		if ! diff -q /tmp/cw_$${name}.out \
				test/expected/$${name}.out \
				> /dev/null 2>&1; then \
			echo "FAIL: $$name (stdout)"; \
			diff /tmp/cw_$${name}.out \
				test/expected/$${name}.out; \
			stdout_ok=0; failed=1; \
		fi; \
		if [ -f test/expected/$${name}.err ]; then \
			if ! diff -q /tmp/cw_$${name}.err \
					test/expected/$${name}.err \
					> /dev/null 2>&1; then \
				echo "FAIL: $$name (stderr)"; \
				diff /tmp/cw_$${name}.err \
					test/expected/$${name}.err; \
				stderr_ok=0; failed=1; \
			fi; \
		elif [ -s /tmp/cw_$${name}.err ]; then \
			echo "FAIL: $$name (unexpected stderr)"; \
			cat /tmp/cw_$${name}.err; \
			stderr_ok=0; failed=1; \
		fi; \
		[ $$stdout_ok -eq 1 ] && [ $$stderr_ok -eq 1 ] \
			&& echo "PASS: $$name"; \
	done; \
	exit $$failed

# Quarto tests — verifies filter produces identical output under Quarto's
# bundled Pandoc. Uses the same expected files as plain Pandoc tests.
test-quarto:
	@failed=0; \
	for f in $(INPUTS); do \
		name=$$(basename $$f .md); \
		for fmt in $(FORMATS); do \
			quarto pandoc --lua-filter=$(FILTER) $$f -t $$fmt \
				> /tmp/cw_$${name}_$${fmt}.out \
				2>/tmp/cw_$${name}_$${fmt}.err; \
			stdout_ok=1; stderr_ok=1; \
			if ! diff -q /tmp/cw_$${name}_$${fmt}.out \
					test/expected/$${name}-$${fmt}.out \
					> /dev/null 2>&1; then \
				echo "FAIL: $$name ($$fmt stdout)"; \
				diff /tmp/cw_$${name}_$${fmt}.out \
					test/expected/$${name}-$${fmt}.out; \
				stdout_ok=0; failed=1; \
			fi; \
			if [ -f test/expected/$${name}-$${fmt}.err ]; then \
				if ! diff -q /tmp/cw_$${name}_$${fmt}.err \
						test/expected/$${name}-$${fmt}.err \
						> /dev/null 2>&1; then \
					echo "FAIL: $$name ($$fmt stderr)"; \
					diff /tmp/cw_$${name}_$${fmt}.err \
						test/expected/$${name}-$${fmt}.err; \
					stderr_ok=0; failed=1; \
				fi; \
			elif [ -s /tmp/cw_$${name}_$${fmt}.err ]; then \
				echo "FAIL: $$name ($$fmt unexpected stderr)"; \
				cat /tmp/cw_$${name}_$${fmt}.err; \
				stderr_ok=0; failed=1; \
			fi; \
			[ $$stdout_ok -eq 1 ] && [ $$stderr_ok -eq 1 ] \
				&& echo "PASS: $$name ($$fmt)"; \
		done; \
	done; \
	exit $$failed

test-quarto-strip:
	@failed=0; \
	for f in $(STRIP_INPUTS); do \
		name=$$(basename $$f .md); \
		quarto pandoc --lua-filter=$(STRIP_FILTER) \
		              --lua-filter=$(FILTER) $$f -t markdown \
			> /tmp/cw_$${name}.out \
			2>/tmp/cw_$${name}.err; \
		stdout_ok=1; stderr_ok=1; \
		if ! diff -q /tmp/cw_$${name}.out \
				test/expected/$${name}.out \
				> /dev/null 2>&1; then \
			echo "FAIL: $$name (stdout)"; \
			diff /tmp/cw_$${name}.out \
				test/expected/$${name}.out; \
			stdout_ok=0; failed=1; \
		fi; \
		if [ -f test/expected/$${name}.err ]; then \
			if ! diff -q /tmp/cw_$${name}.err \
					test/expected/$${name}.err \
					> /dev/null 2>&1; then \
				echo "FAIL: $$name (stderr)"; \
				diff /tmp/cw_$${name}.err \
					test/expected/$${name}.err; \
				stderr_ok=0; failed=1; \
			fi; \
		elif [ -s /tmp/cw_$${name}.err ]; then \
			echo "FAIL: $$name (unexpected stderr)"; \
			cat /tmp/cw_$${name}.err; \
			stderr_ok=0; failed=1; \
		fi; \
		[ $$stdout_ok -eq 1 ] && [ $$stderr_ok -eq 1 ] \
			&& echo "PASS: $$name"; \
	done; \
	exit $$failed

generate-tests:
	@mkdir -p test/expected
	@for f in $(INPUTS); do \
		name=$$(basename $$f .md); \
		for fmt in $(FORMATS); do \
			pandoc --lua-filter=$(FILTER) $$f -t $$fmt \
				> test/expected/$${name}-$${fmt}.out \
				2>test/expected/$${name}-$${fmt}.err.tmp; \
			if [ -s test/expected/$${name}-$${fmt}.err.tmp ]; then \
				mv test/expected/$${name}-$${fmt}.err.tmp \
					test/expected/$${name}-$${fmt}.err; \
			else \
				rm -f test/expected/$${name}-$${fmt}.err.tmp; \
			fi; \
			echo "Generated: $$name ($$fmt)"; \
		done; \
	done

generate-strip-tests:
	@mkdir -p test/expected
	@for f in $(STRIP_INPUTS); do \
		name=$$(basename $$f .md); \
		pandoc --lua-filter=$(STRIP_FILTER) \
		       --lua-filter=$(FILTER) $$f -t markdown \
			> test/expected/$${name}.out \
			2>test/expected/$${name}.err.tmp; \
		if [ -s test/expected/$${name}.err.tmp ]; then \
			mv test/expected/$${name}.err.tmp \
				test/expected/$${name}.err; \
		else \
			rm -f test/expected/$${name}.err.tmp; \
		fi; \
		echo "Generated: $$name"; \
	done

clean:
	rm -f /tmp/cw_*.out /tmp/cw_*.err

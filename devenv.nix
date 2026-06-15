{ pkgs, lib, config, inputs, ... }:

{
  env.GREET = "oc-vhdl";

  packages = with pkgs; [
    ghdl
    gtkwave
    opencode
  ];

  languages.python = {
    enable = true;
    venv.enable = true;
  };

  files = {

  "AGENTS.md".text = ''
# AGENTS.md

Drop-in operating instructions for coding agents. Read this file before every task.

**Working code only. Finish the job. Plausibility is not correctness.**

This file follows the [AGENTS.md](https://agents.md) open standard (Linux Foundation / Agentic AI Foundation). Claude Code, Codex, Cursor, Windsurf, Copilot, Aider, Devin, Amp read it natively. For tools that look elsewhere, symlink:

---

## 0. Non-negotiables

These rules override everything else in this file when in conflict:

1. **No flattery, no filler.** Skip openers like "Great question", "You're absolutely right", "Excellent idea", "I'd be happy to". Start with the answer or the action.
2. **Disagree when you disagree.** If the user's premise is wrong, say so before doing the work. Agreeing with false premises to be polite is the single worst failure mode in coding agents.
3. **Never fabricate.** Not file paths, not commit hashes, not API names, not test results, not library functions. If you don't know, read the file, run the command, or say "I don't know, let me check."
4. **Stop when confused.** If the task has two plausible interpretations, ask. Do not pick silently and proceed.
5. **Touch only what you must.** Every changed line must trace directly to the user's request. No drive-by refactors, reformatting, or "while I was in there" cleanups.

---

## 1. Before writing code

**Goal: understand the problem and the codebase before producing a diff.**

- State your plan in one or two sentences before editing. For anything non-trivial, produce a numbered list of steps with a verification check for each.
- Read the files you will touch. Read the files that call the files you will touch. Claude Code: use subagents for exploration so the main context stays clean.
- Match existing patterns in the codebase. If the project uses pattern X, use pattern X, even if you'd do it differently in a greenfield repo.
- Surface assumptions out loud: "I'm assuming you want X, Y, Z. If that's wrong, say so." Do not bury assumptions inside the implementation.
- If two approaches exist, present both with tradeoffs. Do not pick one silently. Exception: trivial tasks (typo, rename, log line) where the diff fits in one sentence.

---

## 2. Writing code: simplicity first

**Goal: the minimum code that solves the stated problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code. No configurability, flexibility, or hooks that were not requested.
- No error handling for impossible scenarios. Handle the failures that can actually happen.
- If the solution runs 200 lines and could be 50, rewrite it before showing it.
- If you find yourself adding "for future extensibility", stop. Future extensibility is a future decision.
- Bias toward deleting code over adding code. Shipping less is almost always better.

The test: would a senior engineer reading the diff call this overcomplicated? If yes, simplify.

---

## 3. Surgical changes

**Goal: clean, reviewable diffs. Change only what the request requires.**

- Do not "improve" adjacent code, comments, formatting, or imports that are not part of the task.
- Do not refactor code that works just because you are in the file.
- Do not delete pre-existing dead code unless asked. If you notice it, mention it in the summary.
- Do clean up orphans created by your own changes (unused imports, variables, functions your edit made obsolete).
- Match the project's existing style exactly: indentation, quotes, naming, file layout.

The test: every changed line traces directly to the user's request. If a line fails that test, revert it.

---

## 4. Goal-driven execution

**Goal: define success as something you can verify, then loop until verified.**

Rewrite vague asks into verifiable goals before starting:

- "Add validation" becomes "Write tests for invalid inputs (empty, malformed, oversized), then make them pass."
- "Fix the bug" becomes "Write a failing test that reproduces the reported symptom, then make it pass."
- "Refactor X" becomes "Ensure the existing test suite passes before and after, and no public API changes."
- "Make it faster" becomes "Benchmark the current hot path, identify the bottleneck with profiling, change it, show the benchmark is faster."

For every task:

1. State the success criteria before writing code.
2. Write the verification (test, script, benchmark, screenshot diff) where practical.
3. Run the verification. Read the output. Do not claim success without checking.
4. If the verification fails, fix the cause, not the test.

---

## 5. Tool use and verification

- Prefer running the code to guessing about the code. If a test suite exists, run it. If a linter exists, run it. If a type checker exists, run it.
- Never report "done" based on a plausible-looking diff alone. Plausibility is not correctness.
- When debugging, address root causes, not symptoms. Suppressing the error is not fixing the error.
- For UI changes, verify visually: screenshot before, screenshot after, describe the diff.
- Use CLI tools (gh, aws, gcloud, kubectl) when they exist. They are more context-efficient than reading docs or hitting APIs unauthenticated.
- When reading logs, errors, or stack traces, read the whole thing. Half-read traces produce wrong fixes.

---

## 6. Session hygiene

- Context is the constraint. Long sessions with accumulated failed attempts perform worse than fresh sessions with a better prompt.
- After two failed corrections on the same issue, stop. Summarize what you learned and ask the user to reset the session with a sharper prompt.
- Use subagents (Claude Code: "use subagents to investigate X") for exploration tasks that would otherwise pollute the main context with dozens of file reads.
- When committing, write descriptive commit messages (subject under 72 chars, body explains the why). No "update file" or "fix bug" commits. No "Co-Authored-By: Claude" attribution unless the project explicitly wants it.

---

## 7. Communication style

- Direct, not diplomatic. "This won't scale because X" beats "That's an interesting approach, but have you considered...".
- Concise by default. Two or three short paragraphs unless the user asks for depth. No padding, no restating the question, no ceremonial closings.
- When a question has a clear answer, give it. When it does not, say so and give your best read on the tradeoffs.
- Celebrate only what matters: shipping, solving genuinely hard problems, metrics that moved. Not feature ideas, not scope creep, not "wouldn't it be cool if".
- No excessive bullet points, no unprompted headers, no emoji. Prose is usually clearer than structure for short answers.

---

## 8. When to ask, when to proceed

**Ask before proceeding when:**
- The request has two plausible interpretations and the choice materially affects the output.
- The change touches something you've been told is load-bearing, versioned, or has a migration path.
- You need a credential, a secret, or a production resource you don't have access to.
- The user's stated goal and the literal request appear to conflict.

**Proceed without asking when:**
- The task is trivial and reversible (typo, rename a local variable, add a log line).
- The ambiguity can be resolved by reading the code or running a command.
- The user has already answered the question once in this session.

---

## 9. Self-improvement loop

**This file is living. Keep it short by keeping it honest.**

After every session where the agent did something wrong:

1. Ask: was the mistake because this file lacks a rule, or because the agent ignored a rule?
2. If lacking: add the rule under "Project Learnings" below, written as concretely as possible ("Always use X for Y" not "be careful with Y").
3. If ignored: the rule may be too long, too vague, or buried. Tighten it or move it up.
4. Every few weeks, prune. For each line, ask: "Would removing this cause the agent to make a mistake?" If no, delete. Bloated AGENTS.md files get ignored wholesale.

Boris Cherny (creator of Claude Code) keeps his team's file around 100 lines. Under 300 is a good ceiling. Over 500 and you are fighting your own config.

---

## 10. Project context

VHDL hardware design project with GHDL-based simulation and FPGA synthesis target.

### Stack
- Language and version: VHDL IEEE 1076-2008
- Framework(s): none (standalone synthesizable RTL)
- Package manager: devenv + Nix (environment); no VHDL package manager
- Runtime / deployment target: Intel/Altera or Xilinx/AMD FPGAs; simulation via GHDL (open source) or ModelSim/Questa (vendor)

### Commands
- Install: `devenv shell`
- Lint: `ghdl -a --std=08 <file.vhd>` (catches syntax errors, type mismatches, missing signals)
- Typecheck: same as lint (`ghdl -a --std=08`)
- Test (single testbench): `ghdl -a --std=08 <rtl_files...> && ghdl -a --std=08 <tb.vhd> && ghdl -e --std=08 <tb_entity> && ghdl -r --std=08 <tb_entity>`
- Test (with waveform): `ghdl -r --std=08 <tb_entity> --wave=wave.ghw && gtkwave wave.ghw`
- Run locally: `devenv shell`

Prefer single-file or single-test runs during iteration. Full suites are for the final verification pass.

### Layout
- Source lives in: `src/` or `<module>/rtl/` (VHDL sources: entities, architectures, packages)
- Tests live in: `sim/` or `tb/` (testbenches)
- Do not modify: `work/`, `*.cf`, `*.o`, `wave.ghw` (GHDL artifacts); `impl/`, `db/`, `incremental_db/`, `output_files/` (synthesis artifacts); `.devenv/`, `.opencode/`

### Conventions specific to this repo
- Naming: entities and signals `lowercase_with_underscores`; architectures `rtl`; packages `<module>_pkg`; custom types with `_t` suffix; active-low reset named `resetn`
- Import style: always `ieee.numeric_std.all`, never `ieee.std_logic_arith` or `ieee.std_logic_unsigned`
- Processes: `process(all)` for combinational; `process(clk, resetn)` for async reset; `process(clk)` for sync reset; use `rising_edge(clk)` never `clk'event`
- Ports: one per line, 4-space indent, `in`/`out` aligned
- File extension: `.vhd` for all VHDL files
- Testbench pattern: standalone entity with DUT instantiation, `assert`/`severity failure` for checks, `std.env.stop` to end simulation

### Forbidden
- `ieee.std_logic_arith` and `ieee.std_logic_unsigned` — always use `ieee.numeric_std`
- `clk'event` — always use `rising_edge(clk)`
- `process()` without a complete sensitivity list — use `process(all)` for combinational
- Adding generated artifacts to git (`work/`, `*.cf`, `*.o`, `*.ghw`, synthesis output dirs)

---

## 11. Project Learnings

**Accumulated corrections. This section is for the agent to maintain, not just the human.**

When the user corrects your approach, append a one-line rule here before ending the session. Write it concretely ("Always use X for Y"), never abstractly ("be careful with Y"). If an existing line already covers the correction, tighten it instead of adding a new one. Remove lines when the underlying issue goes away (model upgrades, refactors, process changes).

- (empty)

  '';

  ".opencode/skills/vhdl/SKILL.md".text = ''
---
name: vhdl-language
description: Deep expertise in VHDL language constructs, IEEE 1076 standard compliance, and synthesis coding guidelines. Expert skill for generating synthesizable VHDL code.
allowed-tools: Read, Grep, Write, Edit, Bash, Glob
---

# VHDL Language Skill

Expert skill for VHDL (VHSIC Hardware Description Language) development following IEEE 1076 standards. Provides deep expertise in synthesizable VHDL code generation, coding guidelines, and best practices for FPGA design.

## Overview

The VHDL Language skill enables comprehensive VHDL development for FPGA and ASIC designs, supporting:
- IEEE 1076-2019 standard compliance
- Synthesizable code generation
- Entity, architecture, package, and component declarations
- Synchronous process design with proper reset handling
- Vendor-specific synthesis attributes
- Testbench generation with assert statements
- Detection and fix of common coding anti-patterns

## Capabilities

### 1. Entity and Architecture Definition

Generate proper entity and architecture structures:

```vhdl
-- Example: Parameterized FIFO Entity
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_fifo is
  generic (
    DATA_WIDTH : positive := 8;
    DEPTH      : positive := 16;
    ALMOST_FULL_THRESHOLD  : natural := 14;
    ALMOST_EMPTY_THRESHOLD : natural := 2
  );
  port (
    clk           : in  std_logic;
    rst_n         : in  std_logic;
    -- Write interface
    wr_en         : in  std_logic;
    wr_data       : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    full          : out std_logic;
    almost_full   : out std_logic;
    -- Read interface
    rd_en         : in  std_logic;
    rd_data       : out std_logic_vector(DATA_WIDTH-1 downto 0);
    empty         : out std_logic;
    almost_empty  : out std_logic;
    -- Status
    fill_level    : out unsigned(clog2(DEPTH) downto 0)
  );
end entity sync_fifo;

architecture rtl of sync_fifo is
  -- Type declarations
  type ram_type is array (0 to DEPTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

  -- Signal declarations
  signal ram       : ram_type := (others => (others => '0'));
  signal wr_ptr    : unsigned(clog2(DEPTH)-1 downto 0) := (others => '0');
  signal rd_ptr    : unsigned(clog2(DEPTH)-1 downto 0) := (others => '0');
  signal count     : unsigned(clog2(DEPTH) downto 0) := (others => '0');

  -- Function for ceiling log2
  function clog2(n : positive) return natural is
    variable result : natural := 0;
    variable value  : natural := n - 1;
  begin
    while value > 0 loop
      result := result + 1;
      value := value / 2;
    end loop;
    return result;
  end function clog2;

begin
  -- Architecture implementation
end architecture rtl;
```

### 2. Synchronous Process Design

Implement synchronous processes with proper reset handling:

```vhdl
-- Synchronous process with asynchronous reset
process(clk, rst_n)
begin
  if rst_n = '0' then
    -- Asynchronous reset - initialize all registers
    wr_ptr <= (others => '0');
    rd_ptr <= (others => '0');
    count  <= (others => '0');
  elsif rising_edge(clk) then
    -- Synchronous logic
    if wr_en = '1' and full_i = '0' then
      ram(to_integer(wr_ptr)) <= wr_data;
      wr_ptr <= wr_ptr + 1;
    end if;

    if rd_en = '1' and empty_i = '0' then
      rd_ptr <= rd_ptr + 1;
    end if;

    -- Update count
    if (wr_en = '1' and full_i = '0') and not (rd_en = '1' and empty_i = '0') then
      count <= count + 1;
    elsif not (wr_en = '1' and full_i = '0') and (rd_en = '1' and empty_i = '0') then
      count <= count - 1;
    end if;
  end if;
end process;

-- Synchronous process with synchronous reset
process(clk)
begin
  if rising_edge(clk) then
    if sync_rst = '1' then
      -- Synchronous reset
      state <= IDLE;
      counter <= (others => '0');
    else
      -- Normal operation
      state <= next_state;
      counter <= counter + 1;
    end if;
  end if;
end process;
```

### 3. Package and Component Declarations

Create reusable packages and components:

```vhdl
-- Package declaration
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package fpga_utils_pkg is
  -- Constants
  constant CLK_FREQ_HZ : natural := 100_000_000;

  -- Type definitions
  type axi_lite_master_t is record
    awaddr  : std_logic_vector(31 downto 0);
    awvalid : std_logic;
    wdata   : std_logic_vector(31 downto 0);
    wstrb   : std_logic_vector(3 downto 0);
    wvalid  : std_logic;
    bready  : std_logic;
    araddr  : std_logic_vector(31 downto 0);
    arvalid : std_logic;
    rready  : std_logic;
  end record axi_lite_master_t;

  constant AXI_LITE_MASTER_INIT : axi_lite_master_t := (
    awaddr  => (others => '0'),
    awvalid => '0',
    wdata   => (others => '0'),
    wstrb   => (others => '0'),
    wvalid  => '0',
    bready  => '0',
    araddr  => (others => '0'),
    arvalid => '0',
    rready  => '0'
  );

  -- Function declarations
  function clog2(n : positive) return natural;
  function max(a, b : integer) return integer;
  function min(a, b : integer) return integer;

  -- Component declarations
  component sync_fifo is
    generic (
      DATA_WIDTH : positive := 8;
      DEPTH      : positive := 16
    );
    port (
      clk     : in  std_logic;
      rst_n   : in  std_logic;
      wr_en   : in  std_logic;
      wr_data : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      full    : out std_logic;
      rd_en   : in  std_logic;
      rd_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
      empty   : out std_logic
    );
  end component sync_fifo;

end package fpga_utils_pkg;

-- Package body
package body fpga_utils_pkg is

  function clog2(n : positive) return natural is
    variable result : natural := 0;
    variable value  : natural := n - 1;
  begin
    while value > 0 loop
      result := result + 1;
      value := value / 2;
    end loop;
    return result;
  end function clog2;

  function max(a, b : integer) return integer is
  begin
    if a > b then return a; else return b; end if;
  end function max;

  function min(a, b : integer) return integer is
  begin
    if a < b then return a; else return b; end if;
  end function min;

end package body fpga_utils_pkg;
```

### 4. Vendor-Specific Synthesis Attributes

Apply synthesis directives for Xilinx and Intel:

```vhdl
-- Xilinx synthesis attributes
architecture rtl of my_design is
  -- ASYNC_REG for synchronizers
  signal sync_reg : std_logic_vector(1 downto 0);
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of sync_reg : signal is "TRUE";

  -- Keep hierarchy for debugging
  attribute KEEP_HIERARCHY : string;
  attribute KEEP_HIERARCHY of rtl : architecture is "YES";

  -- RAM style control
  signal block_ram : ram_type;
  attribute RAM_STYLE : string;
  attribute RAM_STYLE of block_ram : signal is "block";

  signal dist_ram : small_ram_type;
  attribute RAM_STYLE of dist_ram : signal is "distributed";

  -- Register duplication for fanout
  signal high_fanout_reg : std_logic;
  attribute MAX_FANOUT : integer;
  attribute MAX_FANOUT of high_fanout_reg : signal is 50;

  -- FSM encoding
  type state_type is (IDLE, RUNNING, DONE);
  signal state : state_type;
  attribute FSM_ENCODING : string;
  attribute FSM_ENCODING of state : signal is "one_hot";

begin
  -- Implementation
end architecture rtl;

-- Intel/Altera synthesis attributes
architecture rtl of my_design is
  -- RAM inference control
  signal ram : ram_type;
  attribute ramstyle : string;
  attribute ramstyle of ram : signal is "M20K";

  -- Preserve signal
  signal debug_sig : std_logic;
  attribute preserve : boolean;
  attribute preserve of debug_sig : signal is true;

begin
  -- Implementation
end architecture rtl;
```

### 5. Numeric_std Best Practices

Use numeric_std library correctly (avoid std_logic_arith):

```vhdl
-- CORRECT: Using numeric_std
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;  -- Preferred library

architecture rtl of example is
  signal counter : unsigned(7 downto 0);
  signal signed_val : signed(15 downto 0);
begin
  -- Arithmetic with unsigned
  counter <= counter + 1;
  counter <= counter + to_unsigned(10, counter'length);

  -- Conversion from std_logic_vector
  counter <= unsigned(input_slv);

  -- Conversion to std_logic_vector
  output_slv <= std_logic_vector(counter);

  -- Resize operations
  wide_counter <= resize(counter, wide_counter'length);

  -- Comparison
  if counter > 100 then
    -- ...
  end if;
end architecture rtl;

-- INCORRECT: Avoid std_logic_arith (deprecated)
-- library IEEE;
-- use IEEE.std_logic_arith.all;  -- DO NOT USE
-- use IEEE.std_logic_unsigned.all;  -- DO NOT USE
```

### 6. Testbench Generation

Generate comprehensive testbenches:

```vhdl
-- Testbench example
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sync_fifo_tb is
end entity sync_fifo_tb;

architecture sim of sync_fifo_tb is
  constant CLK_PERIOD : time := 10 ns;
  constant DATA_WIDTH : positive := 8;
  constant DEPTH      : positive := 16;

  signal clk     : std_logic := '0';
  signal rst_n   : std_logic := '0';
  signal wr_en   : std_logic := '0';
  signal wr_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal full    : std_logic;
  signal rd_en   : std_logic := '0';
  signal rd_data : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal empty   : std_logic;

  signal sim_done : boolean := false;

begin
  -- Clock generation
  clk <= not clk after CLK_PERIOD/2 when not sim_done else '0';

  -- DUT instantiation
  dut : entity work.sync_fifo
    generic map (
      DATA_WIDTH => DATA_WIDTH,
      DEPTH      => DEPTH
    )
    port map (
      clk     => clk,
      rst_n   => rst_n,
      wr_en   => wr_en,
      wr_data => wr_data,
      full    => full,
      rd_en   => rd_en,
      rd_data => rd_data,
      empty   => empty
    );

  -- Stimulus process
  stim_proc : process
    variable expected_data : std_logic_vector(DATA_WIDTH-1 downto 0);
  begin
    -- Reset
    rst_n <= '0';
    wait for CLK_PERIOD * 5;
    rst_n <= '1';
    wait for CLK_PERIOD * 2;

    -- Test 1: Write single word
    report "Test 1: Write single word";
    wr_data <= x"A5";
    wr_en <= '1';
    wait for CLK_PERIOD;
    wr_en <= '0';
    wait for CLK_PERIOD;

    assert empty = '0'
      report "FIFO should not be empty after write"
      severity error;

    -- Test 2: Read single word
    report "Test 2: Read single word";
    rd_en <= '1';
    wait for CLK_PERIOD;
    rd_en <= '0';

    assert rd_data = x"A5"
      report "Read data mismatch: expected 0xA5, got " &
             to_hstring(rd_data)
      severity error;

    wait for CLK_PERIOD;
    assert empty = '1'
      report "FIFO should be empty after read"
      severity error;

    -- Test 3: Fill FIFO to full
    report "Test 3: Fill FIFO to full";
    for i in 0 to DEPTH-1 loop
      wr_data <= std_logic_vector(to_unsigned(i, DATA_WIDTH));
      wr_en <= '1';
      wait for CLK_PERIOD;
    end loop;
    wr_en <= '0';

    assert full = '1'
      report "FIFO should be full"
      severity error;

    -- Test complete
    report "All tests passed!" severity note;
    sim_done <= true;
    wait;
  end process stim_proc;

end architecture sim;
```

## Workflow

### 1. Analyze Requirements

```markdown
## Design Requirements Analysis

| Parameter | Value | Notes |
|-----------|-------|-------|
| Clock frequency | 100 MHz | Single clock domain |
| Data width | 32 bits | AXI-compatible |
| Latency | 2 cycles | Pipeline register |
| Reset type | Async active-low | Standard practice |
```

### 2. Generate Module Structure

```bash
# Output files generated:
# - src/<module_name>.vhd      - Main entity and architecture
# - src/<module_name>_pkg.vhd  - Package with types/constants
# - tb/<module_name>_tb.vhd    - Testbench
```

### 3. Validate Code

```bash
# Analyze with GHDL
ghdl -a --std=08 src/module.vhd
ghdl -a --std=08 tb/module_tb.vhd

# Run simulation
ghdl -e --std=08 module_tb
ghdl -r --std=08 module_tb --wave=wave.ghw

## Common Anti-Patterns and Fixes

### Incomplete Sensitivity List

```vhdl
-- INCORRECT: Missing signals in sensitivity list
process(clk)  -- Missing rst_n
begin
  if rst_n = '0' then
    reg <= '0';
  elsif rising_edge(clk) then
    reg <= input;
  end if;
end process;

-- CORRECT: Complete sensitivity list
process(clk, rst_n)  -- Both clk and rst_n included
begin
  if rst_n = '0' then
    reg <= '0';
  elsif rising_edge(clk) then
    reg <= input;
  end if;
end process;
```

### Inferred Latch

```vhdl
-- INCORRECT: Latch inference (incomplete if-else)
process(sel, a, b)
begin
  if sel = '1' then
    output <= a;
  end if;  -- Missing else clause creates latch
end process;

-- CORRECT: Complete combinational logic
process(sel, a, b)
begin
  if sel = '1' then
    output <= a;
  else
    output <= b;  -- All paths covered
  end if;
end process;

-- ALTERNATIVE: Use selected signal assignment
output <= a when sel = '1' else b;
```

## Best Practices

### Coding Style
- Use lowercase for keywords; lowercase_with_underscores for identifiers; UPPERCASE for constants
- One port/signal per line for readability
- Align port declarations vertically
- Use meaningful signal and process names
- Include comments for complex logic

### Synthesis Guidelines
- Always use numeric_std, never std_logic_arith
- Initialize registered signals via reset, not via default value
- Use rising_edge() instead of clk'event and clk='1'
- Apply ASYNC_REG attribute to synchronizers
- Control RAM inference with attributes

### Safety
- Use ASSERT statements for design checking
- Initialize signals with default values
- Document all constraints and assumptions
- Review synthesis warnings carefully

## References

- IEEE Std 1076-2019 (VHDL Language Reference Manual)
- GHDL Documentation: https://ghdl.github.io/ghdl/
- Xilinx UG901: Vivado Synthesis Guide
- Intel Quartus Prime Synthesis Reference
- nandland.com — VHDL tutorials and FPGA design patterns
- vhdlwhiz.com — VHDL best practices and synthesis guidelines
  '';
  };


}

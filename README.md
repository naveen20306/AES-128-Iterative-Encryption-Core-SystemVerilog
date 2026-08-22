#  AES-128 Iterative Encryption Core — SystemVerilog

A **fully custom iterative AES-128 encryption core** implemented in SystemVerilog, built module by module to demonstrate the internal architecture and operation of the Advanced Encryption Standard (AES).

This project implements AES-128 encryption using a **multi-cycle iterative architecture**, where a single AES round datapath is reused across multiple clock cycles.

---

##  Project Overview

This project demonstrates:

- AES-128 encryption based on the standard AES algorithm
- Iterative multi-cycle architecture
- Complete AES round transformation
- AES-128 key expansion
- FSM-based control
- 128-bit plaintext and key processing
- Functional verification using official and additional test vectors

---

##  Key Features

- **AES-128 encryption**
- **Iterative / multi-cycle architecture**
- One reusable AES round datapath
- 11 AES round keys
- 256-entry AES S-box
- SubBytes transformation
- ShiftRows transformation
- MixColumns transformation
- AddRoundKey transformation
- GF(2⁸) multiplication
- FSM-controlled execution
- `start`, `busy`, and `done` handshake signals
- Verified using the official **FIPS-197** test vector

---

##  Architecture

The AES-128 encryption core is organized into independent SystemVerilog modules:

```text
                 ┌─────────────────────┐
Plaintext ──────►│                     │
                 │     AES-128 Core    │──────► Ciphertext
Key ────────────►│                     │
                 │                     │
Start ──────────►│                     │
                 └──────────┬──────────┘
                            │
                            ▼
                    ┌───────────────┐
                    │ Control FSM   │
                    └───────┬───────┘
                            │
                            ▼
              ┌──────────────────────────┐
              │     AES Round Datapath   │
              │                          │
              │ SubBytes                 │
              │ ShiftRows                │
              │ MixColumns               │
              │ AddRoundKey              │
              └──────────────────────────┘
                            ▲
                            │
                    ┌───────┴───────┐
                    │ Key Expansion  │
                    └───────────────┘
```

---

##  Repository Structure

```text
AES128/
├── rtl/
│   ├── aes128_top.sv
│   ├── aes128_fsm.sv
│   ├── aes_round.sv
│   ├── key_expansion.sv
│   ├── sbox.sv
│   ├── sub_bytes.sv
│   ├── shift_rows.sv
│   ├── mix_columns.sv
│   ├── gf_mul.sv
│   └── add_round_key.sv
│
└── tb/
    └── aes128_tb.sv
```

### Module Description

| Module | Description |
|---|---|
| `aes128_top.sv` | Top-level AES-128 encryption core |
| `aes128_fsm.sv` | Controls the complete encryption sequence |
| `aes_round.sv` | Implements one AES encryption round |
| `key_expansion.sv` | Generates all 11 AES-128 round keys |
| `sbox.sv` | 256-entry AES substitution box |
| `sub_bytes.sv` | Performs byte substitution |
| `shift_rows.sv` | Performs row-wise byte shifting |
| `mix_columns.sv` | Performs GF(2⁸) column transformation |
| `gf_mul.sv` | Implements multiplication by 02 and 03 |
| `add_round_key.sv` | Performs XOR with the selected round key |
| `aes128_tb.sv` | Top-level simulation testbench |

---

##  AES-128 Encryption Flow

AES-128 operates on a 128-bit plaintext using a 128-bit key.

```text
128-bit Plaintext
       │
       ▼
Initial AddRoundKey
       │
       ▼
┌─────────────────────┐
│     Round 1         │
│  SubBytes           │
│  ShiftRows          │
│  MixColumns         │
│  AddRoundKey        │
└─────────┬───────────┘
          │
         ...
          │
          ▼
┌─────────────────────┐
│     Round 9         │
│  SubBytes           │
│  ShiftRows          │
│  MixColumns         │
│  AddRoundKey        │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│    Final Round      │
│  SubBytes           │
│  ShiftRows          │
│  AddRoundKey        │
└─────────┬───────────┘
          │
          ▼
     128-bit Ciphertext
```

The final AES round does **not** contain the MixColumns transformation.

---

## AES State Convention

The 128-bit AES block is represented as 16 bytes.

`state[0]` corresponds to the most-significant byte:

```text
state[0]  state[4]  state[8]   state[12]
state[1]  state[5]  state[9]   state[13]
state[2]  state[6]  state[10]  state[14]
state[3]  state[7]  state[11]  state[15]
```

This byte arrangement is used consistently throughout the AES transformations.

---

##  Key Expansion

AES-128 uses:

```text
128-bit Original Key
        │
        ▼
   Key Expansion
        │
        ▼
11 × 128-bit Round Keys
```

The generated round keys are:

```text
Round Key 0
Round Key 1
Round Key 2
   ...
Round Key 10
```

The key expansion is implemented combinationally, allowing the required round key to be selected using the round counter.

---

##  Control FSM

The encryption process is controlled using a finite state machine.

```text
IDLE
  │
  ▼
KEY_EXP
  │
  ▼
ADD_KEY
  │
  ▼
ROUND × 9
  │
  ▼
FINAL_ROUND
  │
  ▼
DONE
  │
  ▼
IDLE
```

The FSM coordinates:

- Key expansion
- Initial AddRoundKey
- AES round execution
- Round counting
- Final round processing
- Ciphertext generation
- `busy` and `done` signals

---

##  Inputs & Outputs

### Inputs

- `clk` → System clock
- `rst` → Reset signal
- `start` → Starts AES encryption
- `plaintext` → 128-bit input plaintext
- `key` → 128-bit AES encryption key

### Outputs

- `ciphertext` → 128-bit encrypted output
- `busy` → Indicates encryption is in progress
- `done` → Indicates that ciphertext is valid

---

##  Verification

The design was simulated using **Icarus Verilog** with SystemVerilog support.

The testbench verifies the AES implementation using multiple known-answer test vectors, including the official **FIPS-197 Appendix B** example.

| Plaintext | Key | Expected Ciphertext | Result |
|---|---|---|---|
| `00112233445566778899AABBCCDDEEFF` | `000102030405060708090A0B0C0D0E0F` | `69C4E0D86A7B0430D8CDB78070B4C55A` | PASS |
| `00000000000000000000000000000000` | `00000000000000000000000000000000` | `66E94BD4EF8A2C3B884CFA59CA342B2E` | PASS |
| `00000000000000000000000000000000` | `FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF` | `A1F6258C877D5FCD8964484538BFC92C` | PASS |

```text
ALL 3 TESTS PASSED
```
---

##  Implementation Details

- **Architecture:** Iterative multi-cycle AES-128
- **Block Size:** 128 bits
- **Key Size:** 128 bits
- **Number of Rounds:** 10
- **Round Keys:** 11
- **S-box:** 256-entry lookup table
- **Round Datapath:** Reused across clock cycles
- **Control:** FSM-based
- **Verification:** Icarus Verilog
- **Standard:** AES / FIPS-197

---

##  Key Concepts Demonstrated

- SystemVerilog RTL design
- AES-128 cryptographic architecture
- Finite State Machine design
- Iterative datapath architecture
- Key scheduling
- Byte-level transformations
- GF(2⁸) arithmetic
- Hardware/software verification methodology
- Testbench-based functional verification

---

##  Contributors

- Naveen Kumar B

---

 **Built from scratch to understand AES at the RTL level.**

# Turn-Based Deck-Building Game (Godot)
<img width="1168" height="669" alt="cardGame" src="https://github.com/user-attachments/assets/4ad6dc4d-3cf0-4a02-817c-b87e3053bc6d" />

## Overview
A single-player, turn-based deck-building game built in **Godot 4** using **GDScript**.  
The project focuses on **modular system design**, **data-driven gameplay**, and **clean separation of concerns**, rather than content completeness.

This repository serves as a systems-focused prototype demonstrating scalable architecture for complex game logic.

---

## Core Systems

### 🃏 Card & Deck System
- Modular card definitions with reusable effects
- Support for temporary, permanent, and upgraded cards
- Effects implemented as composable scripts rather than hardcoded logic

### ⚔️ Turn-Based Combat
- Clear separation between combat state, UI, and resolution logic
- Targeted card play with validation and resolution phases
- Status effects applied and resolved through a centralized system

### 🤖 Enemy AI (Intent-Based)
- Enemies select actions based on visible intents
- AI logic is modular and extensible for new behaviors
- Decision-making separated from execution

### 💬 Dialogue & Encounter Framework
- JSON-driven dialogue with branching choices
- Encounters can transition between dialogue, combat, and shop scenes
- Designed to allow new content without modifying core logic

---

## Technical Highlights
- Data-driven design using JSON and scriptable resources
- Modular architecture to support future expansion
- Clean separation of game logic, presentation, and data
- Emphasis on maintainability and extensibility over one-off solutions

---

## Project Structure (Simplified)


---
name: lead-ama-meetings
description: |
  Prepare weekly AMA (Ask Me Anything) meeting conspect through adaptive interview.
  Reads todo notes, interviews the lead, generates full speech text, saves to Obsidian.

  Use when: "подготовь AMA", "prepare AMA", "давай подготовим встречу", "/ama"
---

# AMA Meeting Preparation

Interactive interview → full speech conspect → save to Obsidian.

**Output:** `~/Git/notes/WORK/01.Встречи/Регулярные/AskMeAnything/AMA YYYY-MM-DD.md`

## Interview Style

Conduct interview in Russian. Be a co-thinker who helps structure thoughts, not just a secretary.

**How to interview:**
- One question at a time. Wait for the answer, then form the next question based on the response.
- Build on answers — if the lead mentioned a topic, ask follow-ups about it.
- After 3-5 questions, briefly summarize what you understood. Catch misunderstandings early.
- When lead says "nothing on this topic" — move on, don't push.
- When lead says "nothing new this week at all" — suggest filler topics (see Phase 3).

## Process

### Phase 1: Context Loading

1. Read todo file: `~/Projects/ama-meetings/todo.md`
2. Find the latest conspect in `~/Git/notes/WORK/01.Встречи/Регулярные/AskMeAnything/` — read it for continuity (previous topics, open threads, promised follow-ups).
3. Determine the next AMA number from the latest conspect heading (e.g., if last was `AMA #1`, next is `AMA #2`).
4. Determine the meeting date — ask the lead or use the upcoming week's date.

**Checkpoint:** You know the AMA number, meeting date, todo notes, and previous meeting context.

Show the lead:
- Topics from todo.md (if any)
- Open threads from previous AMA (if any)
- Ask: "Готов начать подготовку? Есть что-то срочное, что хочешь обсудить первым?"

### Phase 2: Interview

Cover these areas through adaptive questioning. Order is flexible — follow the natural conversation flow.

**Company & Team News:**
- What happened this week in the company that the team should know?
- Any organizational changes, announcements, decisions from above?
- Team-specific news: new hires, departures, role changes, achievements?

**Project & Process Updates:**
- Release status, milestone progress?
- Process changes being introduced or planned?
- Technical decisions made this week that affect the team?
- Blockers, risks, or escalations the team should be aware of?

**Strategic Topics:**
- Any ongoing strategic initiatives to update on? (reference previous AMA threads)
- New directions, experiments, pilots?
- Cross-team collaboration news?

**People & Culture:**
- Anything to celebrate? (team wins, individual achievements)
- Concerns to address? (morale, workload, rumors)
- Feedback loops — anything the lead heard and wants to respond to?

**Q&A Preparation:**
- Any questions the lead expects from the team?
- Sensitive topics that need careful framing?
- Topics to explicitly NOT discuss and why?

**Interview Loop:**
```
1. Pick the least covered area.
2. Ask 1 question about it. Reference todo notes or previous AMA context.
3. Lead responds.
4. Follow up if the answer is vague or opens new threads.
5. When area is covered — move to the next.
6. After all areas — summarize all collected topics.
7. Ask: "Что-то ещё хочешь добавить? Или начинаем формировать конспект?"
```

### Phase 3: Filler Content (if needed)

If the interview produced few topics (less than 15 minutes of content), suggest filler topics.
The lead values content about team management, antifragility, and growth.

**Suggest 2-3 topics from these categories:**
- Team dynamics and communication patterns
- Engineering leadership practices
- Antifragility and resilience in teams
- Feedback culture and psychological safety
- Decision-making frameworks
- Technical excellence and craftsmanship
- Career development and growth mindset
- Cross-functional collaboration
- Managing change and uncertainty

Present each suggestion as: topic name + 2-sentence pitch of what to tell the team.
Let the lead pick which ones to include.

For selected filler topics — write the full speech text yourself based on your knowledge.
The lead will review and adjust.

### Phase 4: Conspect Generation

Generate the full conspect following this structure:

**1. Metadata header** (plain text, before the first heading):

Required fields:
- `Ключевые сообщения:` — 2-3 main takeaways as bullet points

Optional fields (include only if relevant to this meeting):
- `Фаза команды:` — current team phase
- `Стратегический фокус:` — strategic focus
- `Тип изменений:` — type of changes being discussed
- `Ожидаемое сопротивление:` — expected pushback
- `Action items с прошлой встречи:` — follow-ups from previous AMA
- Any other contextual metadata that emerged from the interview

**2. Main heading:**
```
# AMA #N — Full speech text
```

**3. Body blocks:**

Each major topic gets a block with:
- Block header: `# 🟦 Block name (X-Y minutes)` for major topic groups
- Section headers: `## N️⃣ Section name` with emoji numbers
- Full speech text — complete sentences the lead can read aloud
- Bullet lists for enumerations within the speech
- `---` separators between sections
- Estimate timing for each block

**4. Closing section:**
- Summary of key points discussed
- Invitation for questions
- Open, direct tone

**Writing rules:**
- Write in Russian, first person (the lead's voice)
- Tone: direct, honest, conversational — not corporate-speak
- Short sentences. Break long thoughts into separate lines.
- Use line breaks for emphasis (new line = pause when reading)
- Total meeting length: aim for 30-45 minutes of speech content
- Leave room for Q&A (not scripted, just the invitation)

### Phase 5: Review & Save

1. Show the full conspect to the lead.
2. Ask: "Хочешь что-то изменить, добавить или убрать?"
3. Iterate until the lead approves.
4. Save to: `~/Git/notes/WORK/01.Встречи/Регулярные/AskMeAnything/AMA YYYY-MM-DD.md`
5. Clear todo.md — replace content with the empty template:
   ```
   # AMA ToDo

   Weekly scratch pad — drop notes, links, topics here throughout the week.
   These serve as anchor points for the interview session.

   ---

   ```
6. Confirm: "Конспект сохранён в Obsidian. ToDo очищен. Удачной встречи!"

## Self-Verification

Before presenting the conspect to the lead, verify:
- [ ] Metadata header has "Ключевые сообщения" field
- [ ] All topics from the interview are covered in the conspect
- [ ] All items from todo.md are addressed (or explicitly skipped with lead's agreement)
- [ ] Open threads from previous AMA are followed up on (or noted as still open)
- [ ] AMA number is correct (sequential)
- [ ] Estimated total timing is 30-45 minutes
- [ ] Tone is conversational, not corporate
- [ ] Text is ready to read aloud — no placeholders, no "[expand here]"

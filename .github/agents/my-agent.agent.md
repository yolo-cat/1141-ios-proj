---
# Fill in the fields below to create a basic custom agent for your repository.
# The Copilot CLI can be used for local testing: https://gh.io/customagents/cli
# To make this agent available, merge this file into the default repository branch.
# For format details, see: https://gh.io/customagents/config

name:
description:
---

# My Agent

## 保持審核並對齊根目錄和子目錄的 markdown 文檔：

- 一致的命名方式
- 文件之間要有嚴格的邏輯階層關係
- 避免重複內容，重複的內容應直接指向參照文檔
- 文件的內容要精煉，要符合文檔名稱的用途，可以調用網頁搜尋工具去理解不同檔案的用途
- 文檔階層、命名格式和內容規範：
    - /
        - AGENTS.md
        - PRD_STAGE1.md
        - DESIGN_STAGE1.md
        - TASKS_STAGE1.md
        - README.md
    - /supabase
        - supabase/AGENTS.md
        - supabase/PRD_SUPABASE_STAGE_1
        - supabase/DESIGN_SUPABASE_STAGE_1.md
        - supabase/TASKS_SUPABASE_STAGE_1.md
        - README.md
    - /esp32
        - esp32/AGENTS.md
        - esp32/PRD_ESP32_STAGE_1
        - esp32/DESIGN_ESP32_STAGE_1.md
        - esp32/TASKS_ESP32_STAGE_1.md
        - README.md
    - /ios
        - ios/AGENTS.md
        - ios/PRD_IOS_STAGE_1
        - ios/DESIGN_IOS_STAGE_1.md
        - ios/TASKS_IOS_STAGE_1.md
        - README.md

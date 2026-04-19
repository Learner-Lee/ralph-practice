#!/usr/bin/env python3
import sys
import json
import os
import uuid
from datetime import datetime

DATA_FILE = os.path.join(os.path.dirname(__file__), "notes.json")


def load_notes():
    if not os.path.exists(DATA_FILE):
        return []
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def save_notes(notes):
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(notes, f, ensure_ascii=False, indent=2)


def main():
    if len(sys.argv) < 2:
        print("用法: notes.py <命令> [参数]")
        print("命令: add <内容> | list | delete <ID> | search <关键词>")
        sys.exit(1)

    cmd = sys.argv[1]

    if cmd == "add":
        if len(sys.argv) < 3:
            print("用法: notes.py add <内容>")
            sys.exit(1)
        content = " ".join(sys.argv[2:])
        notes = load_notes()
        note = {
            "id": str(uuid.uuid4())[:8],
            "created_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "content": content,
        }
        notes.append(note)
        save_notes(notes)
        print(f"已添加笔记 [ID: {note['id']}]: {note['content']}")

    elif cmd == "list":
        notes = load_notes()
        if not notes:
            print("暂无笔记")
        else:
            for note in notes:
                summary = note["content"][:50]
                print(f"[{note['id']}] {note['created_at']} - {summary}")

    elif cmd == "search":
        if len(sys.argv) < 3:
            print("用法: notes.py search <关键词>")
            sys.exit(1)
        keyword = " ".join(sys.argv[2:])
        notes = load_notes()
        results = [n for n in notes if keyword in n["content"]]
        if not results:
            print("未找到匹配的笔记")
        else:
            for note in results:
                print(f"[{note['id']}] {note['created_at']} - {note['content']}")

    elif cmd == "delete":
        if len(sys.argv) < 3:
            print("用法: notes.py delete <ID>")
            sys.exit(1)
        target_id = sys.argv[2]
        notes = load_notes()
        new_notes = [n for n in notes if n["id"] != target_id]
        if len(new_notes) == len(notes):
            print(f"错误：找不到 ID 为 {target_id} 的笔记")
        else:
            save_notes(new_notes)
            print(f"已删除笔记 [ID: {target_id}]")


if __name__ == "__main__":
    main()

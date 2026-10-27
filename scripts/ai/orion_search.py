#!/usr/bin/env python3
import sys
import os
import argparse
import json
import urllib.request
import urllib.parse
import re

# Read Tavily key
def get_tavily_key():
    conf_path = os.path.expanduser("~/.config/caelestia/shell.json")
    try:
        with open(conf_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            key = data.get("ai", {}).get("tavilyApiKey", "")
            if key: return key
    except Exception:
        pass
    env_key = os.environ.get("TAVILY_API_KEY", "")
    if env_key: return env_key
    return "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"

def search_tavily(query, max_results=5):
    api_key = get_tavily_key()
    try:
        url = "https://api.tavily.com/search"
        payload = {
            "api_key": api_key,
            "query": query,
            "max_results": max_results,
            "search_depth": "advanced",
            "include_answer": True
        }
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})
        
        with urllib.request.urlopen(req, timeout=15) as resp:
            res = json.loads(resp.read().decode("utf-8"))
            output = []
            if res.get("answer"):
                output.append(f"Direct Answer:\n{res['answer']}\n")
            results = res.get("results", [])
            for r in results:
                title = r.get("title", "")
                r_url = r.get("url", "")
                content = r.get("content", "")
                output.append(f"Title: {title}\nURL: {r_url}\nSnippet: {content}")
            if not output:
                return "No useful results returned by search."
            return "\n\n".join(output)
    except Exception as e:
        return f"Search failed: {str(e)}"

def read_webpage(url):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:130.0) Gecko/20100101 Firefox/130.0"})
        with urllib.request.urlopen(req, timeout=15) as resp:
            html = resp.read().decode("utf-8", errors="ignore")
            clean = re.sub(r'<(script|style|nav|footer|header|aside)[^>]*>.*?</\1>', '', html, flags=re.DOTALL | re.IGNORECASE)
            clean = re.sub(r'<[^>]+>', ' ', clean)
            clean = ' '.join(clean.split())
            if len(clean) > 8000:
                clean = clean[:8000] + "\n\n[Content truncated]"
            return clean if clean else "Could not extract text."
    except Exception as e:
        return f"Error reading webpage: {str(e)}"

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["search", "read"], required=True)
    parser.add_argument("--query", type=str, help="Search query")
    parser.add_argument("--page", type=int, default=1, help="Page number (1-indexed)")
    parser.add_argument("--url", type=str, help="URL to read")
    
    args = parser.parse_args()
    
    if args.mode == "search":
        if not args.query:
            print("Error: --query is required for search mode")
            sys.exit(1)
        print(search_tavily(args.query))
    elif args.mode == "read":
        if not args.url:
            print("Error: --url is required for read mode")
            sys.exit(1)
        print(read_webpage(args.url))

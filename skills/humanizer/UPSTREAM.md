# Upstream

`SKILL.md` and `LICENSE` are vendored **unmodified** from
[blader/humanizer](https://github.com/blader/humanizer) (MIT, © 2025 Siqi Chen).

| | |
|---|---|
| Skill version | 3.0.0 |
| Commit | `9862685f575c65a8247f90369951df1b3416e3d6` |
| Vendored on | 2026-09-14 |

Keep the file byte-identical to upstream so updating stays a copy, not a merge:

```bash
git clone --depth 1 https://github.com/blader/humanizer /tmp/humanizer
diff /tmp/humanizer/SKILL.md skills/humanizer/SKILL.md
```

If local changes ever become necessary, follow the `brainstorming` convention:
keep the original beside the edited copy as `SKILL.upstream.md` and say what
diverged and why.

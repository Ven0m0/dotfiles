TODO:

**Pacman modules**

```markdown
/usr/share/libalpm/scripts/
/etc/pacman.d/hooks


systemctl list-units --type=service --state=running

# ffmpeg encode:
mkdir transcoded; for i in *.mp4; do ffmpeg -n -hwaccel cuda -i "$i" -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov "transcoded/${i%.*}.mov"; done
```

<https://github.com/hollowillow/scripts/blob/main/fzman>

```

# Claude

```sh
claude plugin marketplace add wshobson/agents
```

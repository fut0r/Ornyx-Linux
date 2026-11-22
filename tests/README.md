# Validation

From the repository root, run `git diff --check` for working changes and `git diff --cached --check` for staged changes. Check relative documentation links and verify that each changed GitHub issue form parses as YAML. Use `git check-ignore build/test.log out/test.iso sample.iso` to confirm artifact exclusions.

When image definitions arrive, test each affected edition on x86_64 and record the input revision and result. Changes to shared inputs require checks on both GNOME and KDE. Keep test output in the ignored build directory.

# Bash Security Patterns

## Secret handling

### Never expose secrets in:
- Command-line arguments (`ps aux` exposes these)
- Environment variables exported to child processes (when avoidable)
- Log output or error messages
- Shell history

### Safe patterns:

```bash
# Read from user (silent)
read -rs API_KEY
echo ""  # Newline after silent read

# Pass to command via stdin
az keyvault secret set --value @- <<<"$API_KEY"

# Mask in output
if [[ ${#SECRET} -ge 16 ]]; then
    echo "Value: ${SECRET:0:4}****"
else
    echo "Value: [hidden]"
fi
```

## External data validation

Data from external sources (APIs, user input, files) should be:

1. **Fetched securely**: HTTPS only for security-relevant data
2. **Validated before use**: Check format, length, allowed characters
3. **Quoted when used**: Always `"$variable"` to prevent word splitting

```bash
# Validate IP address format
if [[ ! "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    error_exit "Invalid IP address format: $IP"
fi
```

## Cleanup safety

When scripts add then remove resources (ACLs, policies, temp files):

1. **Track creation state**: Only remove what you created
2. **Check pre-existing state**: Skip creation if resource exists
3. **Handle partial failure**: Clean up successfully-created resources even if later steps fail

```bash
POLICY_ADDED=false

# Check if policy already exists
if ! has_policy; then
    add_policy
    POLICY_ADDED=true
fi

# In cleanup
if [[ "$POLICY_ADDED" == "true" ]]; then
    remove_policy
fi
```

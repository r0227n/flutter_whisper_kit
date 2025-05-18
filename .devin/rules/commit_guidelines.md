# Commit Guidelines

- Keep commits appropriately granular so the progress can be clearly understood from the pull request.  
- All commit messages must be written in **English**.

## Conventional Commits Format

We use the [Conventional Commits specification](https://www.conventionalcommits.org/) for our commit messages. This format allows for automated changelog generation and makes it easier to understand the purpose of each commit.

### Basic Structure

```
<type>(<optional scope>): <description>

<optional body>

<optional footer>
```

### Commit Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation changes
- `style`: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- `refactor`: Code changes that neither fixes a bug nor adds a feature
- `test`: Adding or correcting tests
- `chore`: Changes to the build process or auxiliary tools

### Examples of Valid Commit Messages

```
feat(auth): add user authentication flow
fix(ui): resolve overflow in dashboard layout
docs: update README with setup instructions
test(api): add unit tests for REST client
```

### Commit Message Validation

Commit messages will be automatically validated using commitlint when you attempt to commit changes. If your commit message doesn't meet the required format, the commit will be rejected with an error message explaining what's wrong.

To test your commit message format before committing, you can use:

```
echo "your commit message" | npx commitlint
```

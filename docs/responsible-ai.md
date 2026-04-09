# Responsible AI — Detailed Guidance

When building software with AI-assisted tools like GitHub Copilot CLI, it is important to follow Responsible AI practices. This document summarizes Microsoft's Responsible AI principles and provides actionable guidance for developers.

## Microsoft's Six Principles of Responsible AI

Microsoft's [Responsible AI Standard](https://www.microsoft.com/ai/responsible-ai) is built on six core principles. These apply whether you are training models, consuming AI services, or using AI-powered developer tools.

### 1. Fairness

AI systems should treat all people fairly and avoid affecting similarly situated groups in different ways. When using AI-generated code, review outputs for assumptions or biases — for example, hard-coded locale assumptions, gender-biased variable names, or datasets that aren't representative.

**In practice:**

- Review AI-generated code for cultural or demographic assumptions.
- Test with diverse inputs and edge cases.
- Use inclusive language in prompts, code, and documentation.

### 2. Reliability & Safety

AI systems should perform reliably and safely under both expected and unexpected conditions. AI-generated code must be tested and validated just like human-written code — it is not inherently correct.

**In practice:**

- Never ship AI-generated code without review and testing.
- Validate outputs against your specification and acceptance criteria.
- Treat AI suggestions as a starting point, not a final answer.

### 3. Privacy & Security

AI systems should respect privacy and protect personal and business information. Be mindful of what data you include in prompts or share with AI-powered tools.

**In practice:**

- Do not paste secrets, credentials, or personal data into AI prompts.
- Understand your tool's data handling policies (e.g., [GitHub Copilot privacy](https://docs.github.com/en/copilot/responsible-use-of-github-copilot-features)).
- Follow your organization's data classification and handling policies.

### 4. Inclusiveness

AI systems should empower everyone and engage people of all abilities. When AI helps generate user-facing content or interfaces, ensure the results are accessible and inclusive.

**In practice:**

- Ensure AI-generated UI code includes proper accessibility attributes (ARIA labels, semantic HTML, keyboard navigation).
- Consider localization and internationalization from the start.
- Design for diverse users, including those with disabilities.

### 5. Transparency

AI systems should be understandable. Users and stakeholders should know when AI has been used and understand its limitations.

**In practice:**

- Document when and how AI tools were used in your development process.
- Be transparent with your team about AI-assisted contributions.
- Understand that AI models can hallucinate — outputs may look correct but be factually wrong.

### 6. Accountability

People are accountable for AI systems they design, deploy, and use. The developer — not the AI tool — is responsible for the final code.

**In practice:**

- You own the code you commit, regardless of how it was generated.
- Establish code review processes that account for AI-generated code.
- Maintain human oversight and decision-making authority.

## Applying Responsible AI in This Workshop

This workshop uses GitHub Copilot CLI as an AI-assisted development tool. Here is how the principles apply:

| Principle | Workshop Application |
|---|---|
| **Fairness** | Review generated code for biased assumptions |
| **Reliability & Safety** | Validate all outputs against the SDD specification |
| **Privacy & Security** | Avoid sharing sensitive data in prompts |
| **Inclusiveness** | Ensure generated code meets accessibility standards |
| **Transparency** | Acknowledge AI assistance in your workflow |
| **Accountability** | You are responsible for every line you commit |

## Key Takeaways

1. **AI is a tool, not an authority.** Always review, test, and validate AI-generated outputs.
2. **Keep humans in the loop.** Maintain meaningful human oversight at every stage.
3. **Protect sensitive data.** Be deliberate about what you share with AI systems.
4. **Build inclusively.** Use AI to help reach more people, not fewer.
5. **Stay accountable.** The developer is always responsible for the final product.

## Further Reading

- [Microsoft Responsible AI Principles](https://www.microsoft.com/ai/responsible-ai)
- [Microsoft Responsible AI Standard v2 (PDF)](https://blogs.microsoft.com/wp-content/uploads/prod/sites/5/2022/06/Microsoft-Responsible-AI-Standard-v2-General-Requirements-3.pdf)
- [What is Responsible AI? — Azure Machine Learning](https://learn.microsoft.com/azure/machine-learning/concept-responsible-ai)
- [GitHub Copilot Responsible Use](https://docs.github.com/en/copilot/responsible-use-of-github-copilot-features)
- [Microsoft AI Learning Path — Responsible AI](https://learn.microsoft.com/training/paths/responsible-ai-business-principles/)

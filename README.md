# AI for Everyday Coding

This tutorial provides a practical introduction to AI tools for accelerating everyday coding tasks in computational research. Major tool categories (chat interfaces, autocomplete, and full-project AI IDEs) are reviewed and compared to illustrate when each is most helpful. Environmental considerations of AI use are also highlighted. It is designed for researchers at varying levels of coding and cluster experience and will include interactive demonstrations in RStudio and VS Code. Users will leave with concrete skills and best practices for incorporating AI into their day-to-day scientific coding workflows, including assistance with debugging, generating boilerplate, interacting with the command line, and rapidly scaffolding new projects.

## Preface

- I do not claim to be an AI expert, but I code a lot and have benefited from these tools
- My background:
    - PhD in Biostatistics @ Harvard, BS in Statistics and Data Science @ Cal Poly SLO
    - I’ve made R packages, python packages, jupyter lab extensions, shiny apps, bookdowns, quarto and rmd websites, parameterized rmd reports -- AI tools make all of these things easier
- You may benefit from this tutorial if…
    - You write code regularly and work with data
    - You’re interested in lightweight tools that fit naturally into your existing workflow
    - You want to get better output from LLMs but don’t need to understand their internal architecture
    - You want AI to *help you do research*
- You may not like this if…
    - You’re hoping to learn how LLMs work or how to train AI models
    - You’re looking for cutting-edge agentic workflows, autonomous systems, or the heaviest models.
    - You’re a software engineer or otherwise needing system-level integration or production ML engineering
    - You want AI to *do research for you*

## Structure

- [`AI_for_everyday_coding.pdf`](AI_for_everyday_coding.pdf): Slides introducing AI tools and prompting best practices
- [`tutorial`](tutorial): Start here after reviewing the slides!
    - [`instructions.md`](tutorial/instructions.md): step-by-step instructions for this tutorial (think of as your assignment sheet)
    - [`part1.qmd`](tutorial/part1.qmd): contains sample queries and responses for Part 1 of the tutorial (though I recommend following the instructions and devising prompts on your own!).
    - [`part2to5.qmd`](part2to5.qmd): quarto notebook for Parts 2-5 of the tutorial
        - This includes code you should've gotten in Part 1
        - This includes comments to get you started with Parts 2-5
        - Use this side by side with `instructions.md`
- (optional) [`stepwise`](stepwise): This includes example notebook stages at various points in the tutorial (think of as one possible answer key)
    - [`2_3_copilot.qmd`](stepwise/2_3_copilot.qmd): after completing Part 2 and 3
    - [`4_refactor.qmd`](stepwise/4_refactor.qmd): after completing Part 4
    - [`5_agentic`](stepwise/5_agentic): directory created by completing Part 5 with example output files

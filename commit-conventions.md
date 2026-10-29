Commit Conventions
Rules for writing a commit message

git commit -m  "Tag_1:Tag_2 MESSAGE"

git commit -m "MOD:ENH Added linear regression to toolstack"

Where to commit? (Tag_1)

    API - Application Programming Interface related
    CI - Continuous Integration related
    COM - Communication (e.g. E-Mail, APX) related
    DAT - Data and Database related
    DEP - Dependencies related
    DOC  - Documentation related
    DPLY - Deployment related
    ENV - Environment related
    EXP - Explorations
    IDE - Integrated Development Environment related
    MET - Metadata related
    MOD - Model related
    NBK - Notebook related
    OPS - Operations related
    ORG - Organisation related
    PPL - Pipeline related
    PRE - Data Preprocessing related
    SEC - IT Security related
    SEL - Feature selection
    SUB - Submodule related
    TRA - Data Transformation related
    TEST - Software Testing related

What to commit? (Tag_2)

    BFX - A bug fix. Correlates with PATCH in SemVer
    BREAK - A breaking change. Correlates with MAJOR in SemVer
    BUG - An intentionally created bug to test error handling.
    DEL - Delete Script/Function/Class. Correlates with MINOR in SemVer
    DOCS - Documentation only changes
    ENH - Enhancement. Correlates with MINOR in SemVer
    FEAT - A new feature. Correlates with MINOR in SemVer
    ICM - Initial Commit of New Script/Class/Function. Correlates with MINOR in SemVer
    PERF - A code change that improves performance. Correlates with PATCH in SemVer
    REF - A code change that neither fixes a bug nor adds a feature
    STYLE - Changes that do not affect the meaning of the code (white-space, formatting)
    TEST - Adding missing or correcting existing tests

Skip CI-Pipeline

Depending on wether and how your CI/CD pipeline is set up, your CI-tool will automatically start a new build job with every commit you make. Sometimes you don't want to trigger the CI pipeline, e.g. when you fix some spelling error. In this case you can write [CI SKIP] in front of your commit message and thus skipping CI in this commit.

Here is an example:

commit -m "[CI SKIP] DOC:BFX fixed a spelling error."

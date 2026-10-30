Commit Conventions
Rules for writing a commit message

git commit -m  "\[Tag_1:Tag_2\] MESSAGE"

git commit -m "\[MOD:ENH\] Added linear regression to toolstack"

Where to commit? (Tag_1)

    API - Application Programming Interface related
    CI - Continuous Integration related
    DAT - Data and Database related
    DEP - Dependencies related
    DOC  - Documentation related
    DPLY - Deployment related
    ENV - Environment related
    IDE - Integrated Development Environment related
    MOD - Model related
    OPS - Operations related
    ORG - Organisation related
    SEC - IT Security related
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

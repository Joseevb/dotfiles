local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local rep = ls.rep                            -- Node for repeating previous insert nodes
local fmt = require("luasnip.extras.fmt").fmt -- String formatting utility

-- Optional: Import other node types if needed
-- local t = ls.text_node
-- local d = ls.dynamic_node
-- local f = ls.function_node
-- local c = ls.choice_node

return {                                                                -- Add this snippet to the table returned by the file

    s(                                                                  -- Define the snippet
        {
            trig = "jpaeqhc",                                           -- Trigger keyword: type 'jpaeqhc' and expand
            namr = "JPA Equals & HashCode",                             -- Name (optional, for UI/description)
            dscr = "Adds JPA-safe equals() and hashCode() methods based on ID.", -- Description
        },
        fmt(                                                            -- Use fmt to format the string with placeholders
            [[
// --- Recommended equals() and hashCode() for JPA entities ---
// Based on non-null ID check for persistent entities, and object identity for transient ones.
// Assumes primary key field name is '{}'

@Override
public boolean equals(Object o) {{
    if (this == o) return true;
    // Use getClass() comparison for JPA proxy safety
    if (o == null || getClass() != o.getClass()) return false;
    {} that = ({}) o; // Cast to the current entity type
    // If ID ({}) is null (transient state), objects are only equal if they are the same instance (this == o passed).
    // If ID ({}) is not null (persistent state), compare by ID.
    return {} != null && java.util.Objects.equals({}, that.{}); // Use fully qualified Objects for safety in snippet
}}

@Override
public int hashCode() {{
    // Consistent with equals.
    // Use ID's ({}) hashcode ONLY if ID is not null (persistent).
    // Use a stable value (like getClass().hashCode()) for ALL transient instances.
    return {} != null ? java.util.Objects.hashCode({}) : getClass().hashCode(); // Use fully qualified Objects
}}
    ]],
            {
                -- Define the placeholders used by fmt above, in order of '{}' appearance:
                i(2, "id"),  -- 1st {}: Placeholder for the PK field name ($2, default "id")
                i(1, "YourEntityClass"), -- 2nd {}: Placeholder for Class Name ($1, default "YourEntityClass")
                rep(1),      -- 3rd {}: Repeat the Class Name placeholder ($1)
                rep(2),      -- 4th {}: Repeat the PK field name ($2) comment marker
                rep(2),      -- 5th {}: Repeat the PK field name ($2) null check
                rep(2),      -- 6th {}: Repeat the PK field name ($2) Objects.equals first arg
                rep(2),      -- 7th {}: Repeat the PK field name ($2) Objects.equals second arg
                rep(2),      -- 8th {}: Repeat the PK field name ($2) comment marker hashcode
                rep(2),      -- 9th {}: Repeat the PK field name ($2) hashCode null check
                rep(2),      -- 10th {}:Repeat the PK field name ($2) hashCode Objects.hashCode arg
            }
        )                    -- End of fmt call
    ),                       -- End of snippet definition s()
}                            -- End of the returned table

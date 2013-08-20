CALL ASSERT_EQUALS(PCRE_SEARCH('FOO', 'FOOBAR'), 1);
CALL ASSERT_EQUALS(PCRE_SEARCH('BAR', 'FOOBAR'), 4);
CALL ASSERT_EQUALS(PCRE_SEARCH('BAZ', 'FOOBAR'), 0);
CALL ASSERT_EQUALS(PCRE_SEARCH('\b\d{1,3}(\.\d{1,3}){3}\b', '192.168.0.1'), 1);
CALL ASSERT_EQUALS(PCRE_SEARCH('<([A-Z][A-Z0-9]*)[^>]*>.*?</\1>', '<B>BOLD!</B>'), 1);
CALL ASSERT_EQUALS(PCRE_SEARCH('Q(?!U)', 'QUACK'), 0);
CALL ASSERT_EQUALS(PCRE_SEARCH('Q(?!U)', 'QI'), 1);
CALL ASSERT_EQUALS(PCRE_SUB('FOO', '\0', 'FOOBAR'), 'FOO');
CALL ASSERT_EQUALS(PCRE_SUB('FOO(BAR)?', '\0', 'FOOBAR'), 'FOOBAR');
CALL ASSERT_EQUALS(PCRE_SUB('BAZ', '\0', 'FOOBAR'), NULL);
CALL ASSERT_EQUALS(PCRE_SUB('\b(\d{1,3}(\.\d{1,3}){3})\b', '\1', 'IP address: 192.168.0.1'), '192.168.0.1');
CALL ASSERT_EQUALS(PCRE_SUB('<([A-Z][A-Z0-9]*)[^>]*>(.*?)</\1>', '<I>\2</I>', '<B>BOLD!</B>'), '<I>BOLD!</I>');
CALL ASSERT_EQUALS(PCRE_SUB('Q(?!U)', '\0', 'QUACK'), NULL);
CALL ASSERT_EQUALS(PCRE_SUB('Q(?!U)', '\0', 'QI'), 'Q');

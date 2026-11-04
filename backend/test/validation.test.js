'use strict';

const { validateTitle } = require('../src/tasks/validation');

describe('validateTitle (Section 4)', () => {
  test('trims a valid title', () => {
    expect(validateTitle(' Plan tests ')).toBe('Plan tests');
  });

  test('rejects a blank title', () => {
    expect(() => validateTitle(' ')).toThrow('Enter a valid title.');
  });

  test('rejects a title longer than the limit', () => {
    expect(() => validateTitle('a'.repeat(121))).toThrow();
  });

  // Practice exercise (Section 4):
  test('accepts a valid title at the maximum allowed length (120 characters)', () => {
    const maxTitle = 'a'.repeat(120);
    expect(validateTitle(maxTitle)).toBe(maxTitle);
    expect(validateTitle(maxTitle).length).toBe(120);
  });

  test('rejects non-string input (numbers, objects, null)', () => {
    expect(() => validateTitle(42)).toThrow('Enter a valid title.');
    expect(() => validateTitle(null)).toThrow('Enter a valid title.');
    expect(() => validateTitle(undefined)).toThrow('Enter a valid title.');
    expect(() => validateTitle({})).toThrow('Enter a valid title.');
  });
});

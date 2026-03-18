#!/bin/bash
# Test runner script for Gemified Travel Portfolio

set -e

echo "🧪 Gemified Travel Portfolio - Test Suite"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Parse arguments
TEST_TYPE=${1:-all}
COVERAGE=${2:-false}

run_all_tests() {
    echo -e "${YELLOW}Running all tests...${NC}"
    flutter test
    echo -e "${GREEN}✓ All tests passed${NC}"
}

run_unit_tests() {
    echo -e "${YELLOW}Running unit tests...${NC}"
    flutter test test/unit/
    echo -e "${GREEN}✓ Unit tests passed${NC}"
}

run_widget_tests() {
    echo -e "${YELLOW}Running widget tests...${NC}"
    flutter test test/widget/
    echo -e "${GREEN}✓ Widget tests passed${NC}"
}

run_integration_tests() {
    echo -e "${YELLOW}Running integration tests...${NC}"
    flutter test test/integration/
    echo -e "${GREEN}✓ Integration tests passed${NC}"
}

run_with_coverage() {
    echo -e "${YELLOW}Running tests with coverage...${NC}"
    flutter test --coverage
    echo -e "${GREEN}✓ Coverage report generated${NC}"
    echo "  📊 Report location: coverage/lcov.info"
}

run_specific_test() {
    local test_file=$1
    if [ -f "test/$test_file" ]; then
        echo -e "${YELLOW}Running: $test_file${NC}"
        flutter test "test/$test_file"
        echo -e "${GREEN}✓ Test passed${NC}"
    else
        echo -e "${RED}✗ Test file not found: test/$test_file${NC}"
        exit 1
    fi
}

# Main execution
case $TEST_TYPE in
    all)
        run_all_tests
        if [ "$COVERAGE" = "true" ]; then
            run_with_coverage
        fi
        ;;
    unit)
        run_unit_tests
        if [ "$COVERAGE" = "true" ]; then
            flutter test test/unit/ --coverage
        fi
        ;;
    widget)
        run_widget_tests
        if [ "$COVERAGE" = "true" ]; then
            flutter test test/widget/ --coverage
        fi
        ;;
    integration)
        run_integration_tests
        if [ "$COVERAGE" = "true" ]; then
            flutter test test/integration/ --coverage
        fi
        ;;
    coverage)
        run_with_coverage
        ;;
    *)
        # Assume it's a specific test file
        run_specific_test "$TEST_TYPE"
        ;;
esac

echo ""
echo -e "${GREEN}✓ Test execution completed successfully${NC}"

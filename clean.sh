#!/bin/bash

# ABCMint 代码库清理脚本
# 作用：清理编译产物、运行时数据、临时文件，保留源代码和文档

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "  ABCMint 代码库清理脚本"
echo "=========================================="
echo ""

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 计数器
CLEANED_ITEMS=0
KEPT_ITEMS=0

# 清理函数
clean_item() {
    local item="$1"
    local description="$2"
    
    if [ -e "$item" ]; then
        echo -e "${YELLOW}[清理]${NC} $description: $item"
        rm -rf "$item"
        CLEANED_ITEMS=$((CLEANED_ITEMS + 1))
    fi
}

# 保留函数
keep_item() {
    local item="$1"
    local description="$2"
    
    if [ -e "$item" ]; then
        echo -e "${GREEN}[保留]${NC} $description: $item"
        KEPT_ITEMS=$((KEPT_ITEMS + 1))
    fi
}

echo "第一步：清理编译产物..."
echo "----------------------------------------"

cd src

# 清理可执行文件
clean_item "abcmint" "主程序可执行文件"
clean_item "abcmintrpc" "RPC客户端"
clean_item "test_abcmint" "测试程序"
clean_item "test_pow_verify" "POW验证测试"
clean_item "test_pow_verify.cpp" "POW验证测试源码"
clean_item "test_minimal" "最小测试程序"
clean_item "test_rainbow_simple" "Rainbow测试程序"
clean_item "test_rainbowplus_stack" "RainbowPlus栈测试"
clean_item "test_stack_limit" "栈限制测试"
clean_item "test_stack_limit_64m" "64M栈测试"

# 清理编译中间文件
clean_item "obj/" "编译中间文件目录"
clean_item "obj-test/" "测试编译中间文件"

# 清理临时源文件
clean_item "test_minimal.cpp" "测试源码"
clean_item "test_rainbow_simple.cpp" "测试源码"
clean_item "test_rainbowplus_stack.cpp" "测试源码"
clean_item "test_stack_limit.c" "测试源码"
clean_item "test_stack_sizes.sh" "测试脚本"
clean_item "test_genesis_hash.cpp" "测试源码"

echo ""
echo "第二步：清理运行时数据..."
echo "----------------------------------------"

# 清理区块链数据
clean_item "blocks/" "区块链数据目录"
clean_item "chainstate/" "链状态数据"
clean_item "pubpos/" "公钥位置索引"

# 清理日志和数据库文件
clean_item "debug.log" "调试日志"
clean_item "db.log" "数据库日志"
clean_item ".lock" "锁文件"
clean_item "peers.dat" "节点数据"
clean_item "wallet.dat" "钱包数据(谨慎!)"
clean_item "abcmint.conf" "配置文件(如需保留请注释此行)"

echo ""
echo "第三步：清理备份和临时文件..."
echo "----------------------------------------"

# 清理备份文件
clean_item "init.cpp.bak" "init.cpp备份"
find . -name "*.bak" -type f -exec rm -f {} \; 2>/dev/null && echo -e "${YELLOW}[清理]${NC} 所有.bak备份文件"
find . -name "*.old" -type f -exec rm -f {} \; 2>/dev/null && echo -e "${YELLOW}[清理]${NC} 所有.old备份文件"
find . -name "*.swp" -type f -exec rm -f {} \; 2>/dev/null && echo -e "${YELLOW}[清理]${NC} Vim交换文件"
find . -name ".DS_Store" -type f -exec rm -f {} \; 2>/dev/null && echo -e "${YELLOW}[清理]${NC} macOS .DS_Store文件"

echo ""
echo "第四步：清理依赖库编译产物..."
echo "----------------------------------------"

# LevelDB
if [ -d "leveldb" ]; then
    echo -e "${YELLOW}[清理]${NC} LevelDB编译产物..."
    cd leveldb
    make clean 2>/dev/null || true
    rm -f *.o libleveldb.a libmemenv.a build_config.mk 2>/dev/null || true
    cd ..
    CLEANED_ITEMS=$((CLEANED_ITEMS + 1))
fi

# pqcrypto
if [ -d "pqcrypto" ]; then
    clean_item "pqcrypto/*.o" "pqcrypto目标文件"
    clean_item "pqcrypto/libpqcrypto.a" "pqcrypto静态库"
fi

echo ""
echo "第五步：保留重要文件检查..."
echo "----------------------------------------"

# 检查重要文件是否存在
keep_item "makefile.osx" "macOS构建文件"
keep_item "makefile.unix" "Unix构建文件"
keep_item "librainbowpro/" "RainbowPro密码学库源码"
keep_item "rainbow18/librainbowpro_unix_arm64.a" "RainbowPro预编译库(重要!)"
keep_item "test/" "测试用例目录"
keep_item "qt/" "Qt图形界面源码"
keep_item "leveldb/" "LevelDB源码"

cd ..

# 根目录文件
keep_item "README.md" "项目说明"
keep_item "LICENSE" "许可证"
keep_item "COPYING" "版权信息"
keep_item ".gitignore" "Git忽略规则"

echo ""
echo "=========================================="
echo -e "${GREEN}✓ 清理完成！${NC}"
echo "=========================================="
echo ""
echo "统计信息："
echo "  - 已清理项目: $CLEANED_ITEMS"
echo "  - 保留关键文件: $KEPT_ITEMS"
echo ""
echo "清理结果："
echo "  ✓ 编译产物已清理"
echo "  ✓ 运行时数据已清理"
echo "  ✓ 临时文件已清理"
echo "  ✓ 源代码和文档已保留"
echo ""
echo "提示："
echo "  - 源代码和构建脚本已完整保留"
echo "  - 可以运行 'make -f makefile.osx' 重新编译"
echo "  - 修改后的库文件 librainbowpro_unix_arm64.a 已保留"
echo "  - 栈溢出修复已保留在 librainbowpro/src/rainbow/core/rb_core_blas_matrix_ref.c"
echo ""

if [ -f "./devel/local/bin-config/common.sh" ]; then
    . ./devel/local/bin-config/common.sh
fi
if [ -f "./devel/local/bin-config/$1.sh" ]; then
    . ./devel/local/bin-config/$1.sh
fi

if [ -z "$HELM_CHART" ]; then
    HELM_CHART="./chart"
fi
if [ -z "$HELM_NS" ]; then
    HELM_NS="default"
fi
if [ -z "$HELM_APP" ]; then
    HELM_APP="myapp"
fi
if [ -z "$HELM_VALUES" ]; then
    HELM_VALUES="-f ./templates/starter/starter.generic.yaml -f ./templates/starter/values.yaml"
fi
